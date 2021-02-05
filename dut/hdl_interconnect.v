//==============================================================================
// COPYRIGHT (C) 2005, 2006, 2007, 2008 SYNOPSYS INC.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Abstract:
//    HDL interconnection
//
// Notes:
//    PHY (Test Bench Device) - PcieTxrx representing the testbench (PIPE PHY interface)
//    MAC (Device Under Test) - PcieTxrx representing the MAC (PIPE MAC interface)
//
//     +-----------------+                           +-------------------+
//     |                 |                           |                   |
//     |  PCIE TXRX VIP  |---                     ---|  PCIE TXRX VIP    |
//     |                 |RX |                   |RX |                   |
//     |                 |--- .                 . ---|                   |
//     |                 |     +---------------+     |                   |
//     |                 |     |               |     |                   |
//     |  PIPE PHY mode  |     |      HDL      |     |  PIPE MAC mode    |
//     |                 |     |               |     |                   |
//     |                 |     | INTER-CONNECT |     | (To be replaced   |
//     |                 |     |               |     |   by MAC)         |
//     |                 |     +---------------+     |                   |
//     |                 |    .                 .    |                   |
//     |                 |---                     ---|                   |
//     |                 |TX |                   |TX |                   |
//     |                 |---                     ---|                   |
//     |                 |                           |                   |
//     +-----------------+                           +-------------------+
//
//------------------------------------------------------------------------------

`ifndef PCIE_BASIC_HDL_INTERCONNECT_INCLUDED
 `define PCIE_BASIC_HDL_INTERCONNECT_INCLUDED

`timescale 10 ps/10 ps

//==============================================================================
module hdl_interconnect (

  //----------------------------------------------------------------------------
  // MAC interface ports
  //----------------------------------------------------------------------------
  input mac_clk,

  // mac_lane 0
  output [31:0]   mac_lane0_txdata, 
  output [3:0]    mac_lane0_txdatak,
  input [31:0]    mac_lane0_rxdata,
  input [3:0]     mac_lane0_rxdatak,

  // mac_lane 1
  output [31:0]   mac_lane1_txdata,
  output [3:0]    mac_lane1_txdatak,
  input [31:0]    mac_lane1_rxdata,
  input [3:0]     mac_lane1_rxdatak,

  // mac_lane 2
  output [31:0]   mac_lane2_txdata,
  output [3:0]    mac_lane2_txdatak,
  input [31:0]    mac_lane2_rxdata,
  input [3:0]     mac_lane2_rxdatak,

  // mac_lane 3
  output [31:0]   mac_lane3_txdata,
  output [3:0]    mac_lane3_txdatak,
  input [31:0]    mac_lane3_rxdata,
  input [3:0]     mac_lane3_rxdatak,

  // mac_lane 4
  output [31:0]   mac_lane4_txdata,
  output [3:0]    mac_lane4_txdatak,
  input [31:0]    mac_lane4_rxdata,
  input [3:0]     mac_lane4_rxdatak,

  // mac_lane 5
  output [31:0]   mac_lane5_txdata,
  output [3:0]    mac_lane5_txdatak,
  input [31:0]    mac_lane5_rxdata,
  input [3:0]     mac_lane5_rxdatak,

  // mac_lane 6
  output [31:0]   mac_lane6_txdata,
  output [3:0]    mac_lane6_txdatak,
  input [31:0]    mac_lane6_rxdata,
  input [3:0]     mac_lane6_rxdatak,

  // mac_lane 7
  output [31:0]   mac_lane7_txdata,
  output [3:0]    mac_lane7_txdatak,
  input [31:0]    mac_lane7_rxdata,
  input [3:0]     mac_lane7_rxdatak,

  // mac_lane 8
  output [31:0]   mac_lane8_txdata,
  output [3:0]    mac_lane8_txdatak,
  input [31:0]    mac_lane8_rxdata,
  input [3:0]     mac_lane8_rxdatak,

  // mac_lane 9
  output [31:0]   mac_lane9_txdata,
  output [3:0]    mac_lane9_txdatak,
  input [31:0]    mac_lane9_rxdata,
  input [3:0]     mac_lane9_rxdatak,

  // mac_lane 10
  output [31:0]   mac_lane10_txdata,
  output [3:0]    mac_lane10_txdatak,
  input [31:0]    mac_lane10_rxdata,
  input [3:0]     mac_lane10_rxdatak,

  // mac_lane 11
  output [31:0]   mac_lane11_txdata,
  output [3:0]    mac_lane11_txdatak,
  input [31:0]    mac_lane11_rxdata,
  input [3:0]     mac_lane11_rxdatak,

  // mac_lane 12
  output [31:0]   mac_lane12_txdata,
  output [3:0]    mac_lane12_txdatak,
  input [31:0]    mac_lane12_rxdata,
  input [3:0]     mac_lane12_rxdatak,

  // mac_lane 13
  output [31:0]   mac_lane13_txdata,
  output [3:0]    mac_lane13_txdatak,
  input [31:0]    mac_lane13_rxdata,
  input [3:0]     mac_lane13_rxdatak,

  // mac_lane 14
  output [31:0]   mac_lane14_txdata,
  output [3:0]    mac_lane14_txdatak,
  input [31:0]    mac_lane14_rxdata,
  input [3:0]     mac_lane14_rxdatak,

  // mac_lane 15
  output [31:0]   mac_lane15_txdata,
  output [3:0]    mac_lane15_txdatak,
  input [31:0]    mac_lane15_rxdata,
  input [3:0]     mac_lane15_rxdatak,

  // PCIe PIPE command/status signals
  input [15:0]    mac_txdetectrx,
  input [15:0]    mac_txelecidle,
  input [15:0]    mac_txcompliance,
  input [15:0]    mac_rxpolarity,
  input [15:0]    mac_reset_n,
  input [2:0]     mac_powerdown0,
  input [2:0]     mac_powerdown1,
  input [2:0]     mac_powerdown2,
  input [2:0]     mac_powerdown3,
  input [2:0]     mac_powerdown4,
  input [2:0]     mac_powerdown5,
  input [2:0]     mac_powerdown6,
  input [2:0]     mac_powerdown7,
  input [2:0]     mac_powerdown8,
  input [2:0]     mac_powerdown9,
  input [2:0]     mac_powerdown10,
  input [2:0]     mac_powerdown11,
  input [2:0]     mac_powerdown12,
  input [2:0]     mac_powerdown13,
  input [2:0]     mac_powerdown14,
  input [2:0]     mac_powerdown15,
  input [15:0]    mac_rate,
  input [15:0]    mac_txdeemph,
  input [2:0]     mac_txmargin0,
  input [2:0]     mac_txmargin1,
  input [2:0]     mac_txmargin2,
  input [2:0]     mac_txmargin3,
  input [2:0]     mac_txmargin4,
  input [2:0]     mac_txmargin5,
  input [2:0]     mac_txmargin6,
  input [2:0]     mac_txmargin7,
  input [2:0]     mac_txmargin8,
  input [2:0]     mac_txmargin9,
  input [2:0]     mac_txmargin10,
  input [2:0]     mac_txmargin11,
  input [2:0]     mac_txmargin12,
  input [2:0]     mac_txmargin13,
  input [2:0]     mac_txmargin14,
  input [2:0]     mac_txmargin15,
  input [15:0]    mac_txswing,
  output [15:0]   mac_rxvalid,
  output [15:0]   mac_phystatus,
  output [15:0]   mac_rxelecidle,
  output [2:0]    mac_rxstatus0,
  output [2:0]    mac_rxstatus1,
  output [2:0]    mac_rxstatus2,
  output [2:0]    mac_rxstatus3,
  output [2:0]    mac_rxstatus4,
  output [2:0]    mac_rxstatus5,
  output [2:0]    mac_rxstatus6,
  output [2:0]    mac_rxstatus7,
  output [2:0]    mac_rxstatus8,
  output [2:0]    mac_rxstatus9,
  output [2:0]    mac_rxstatus10,
  output [2:0]    mac_rxstatus11,
  output [2:0]    mac_rxstatus12,
  output [2:0]    mac_rxstatus13,
  output [2:0]    mac_rxstatus14,
  output [2:0]    mac_rxstatus15,
  output          mac_pclk,

  //----------------------------------------------------------------------------
  // PHY interface ports
  //----------------------------------------------------------------------------
  input phy_clk,

  // phy_lane 0
  output [31:0]   phy_lane0_txdata, 
  output [3:0]    phy_lane0_txdatak,
  input [31:0]    phy_lane0_rxdata,
  input [3:0]     phy_lane0_rxdatak,

  // phy_lane 1
  output [31:0]   phy_lane1_txdata,
  output [3:0]    phy_lane1_txdatak,
  input [31:0]    phy_lane1_rxdata,
  input [3:0]     phy_lane1_rxdatak,

  // phy_lane 2
  output [31:0]   phy_lane2_txdata,
  output [3:0]    phy_lane2_txdatak,
  input [31:0]    phy_lane2_rxdata,
  input [3:0]     phy_lane2_rxdatak,

  // phy_lane 3
  output [31:0]   phy_lane3_txdata,
  output [3:0]    phy_lane3_txdatak,
  input [31:0]    phy_lane3_rxdata,
  input [3:0]     phy_lane3_rxdatak,

  // phy_lane 4
  output [31:0]   phy_lane4_txdata,
  output [3:0]    phy_lane4_txdatak,
  input [31:0]    phy_lane4_rxdata,
  input [3:0]     phy_lane4_rxdatak,

  // phy_lane 5
  output [31:0]   phy_lane5_txdata,
  output [3:0]    phy_lane5_txdatak,
  input [31:0]    phy_lane5_rxdata,
  input [3:0]     phy_lane5_rxdatak,

  // phy_lane 6
  output [31:0]   phy_lane6_txdata,
  output [3:0]    phy_lane6_txdatak,
  input [31:0]    phy_lane6_rxdata,
  input [3:0]     phy_lane6_rxdatak,

  // phy_lane 7
  output [31:0]   phy_lane7_txdata,
  output [3:0]    phy_lane7_txdatak,
  input [31:0]    phy_lane7_rxdata,
  input [3:0]     phy_lane7_rxdatak,

  // phy_lane 8
  output [31:0]   phy_lane8_txdata,
  output [3:0]    phy_lane8_txdatak,
  input [31:0]    phy_lane8_rxdata,
  input [3:0]     phy_lane8_rxdatak,

  // phy_lane 9
  output [31:0]   phy_lane9_txdata,
  output [3:0]    phy_lane9_txdatak,
  input [31:0]    phy_lane9_rxdata,
  input [3:0]     phy_lane9_rxdatak,

  // phy_lane 10
  output [31:0]   phy_lane10_txdata,
  output [3:0]    phy_lane10_txdatak,
  input [31:0]    phy_lane10_rxdata,
  input [3:0]     phy_lane10_rxdatak,

  // phy_lane 11
  output [31:0]   phy_lane11_txdata,
  output [3:0]    phy_lane11_txdatak,
  input [31:0]    phy_lane11_rxdata,
  input [3:0]     phy_lane11_rxdatak,

  // phy_lane 12
  output [31:0]   phy_lane12_txdata,
  output [3:0]    phy_lane12_txdatak,
  input [31:0]    phy_lane12_rxdata,
  input [3:0]     phy_lane12_rxdatak,

  // phy_lane 13
  output [31:0]   phy_lane13_txdata,
  output [3:0]    phy_lane13_txdatak,
  input [31:0]    phy_lane13_rxdata,
  input [3:0]     phy_lane13_rxdatak,

  // phy_lane 14
  output [31:0]   phy_lane14_txdata,
  output [3:0]    phy_lane14_txdatak,
  input [31:0]    phy_lane14_rxdata,
  input [3:0]     phy_lane14_rxdatak,

  // phy_lane 15
  output [31:0]   phy_lane15_txdata,
  output [3:0]    phy_lane15_txdatak,
  input [31:0]    phy_lane15_rxdata,
  input [3:0]     phy_lane15_rxdatak,

  // PCIe PIPE command/status signals
  output [15:0]   phy_txdetectrx,
  output [15:0]   phy_txelecidle,
  output [15:0]   phy_txcompliance,
  output [15:0]   phy_rxpolarity,
  output [15:0]   phy_reset_n,
  output [2:0]    phy_powerdown0,
  output [2:0]    phy_powerdown1,
  output [2:0]    phy_powerdown2,
  output [2:0]    phy_powerdown3,
  output [2:0]    phy_powerdown4,
  output [2:0]    phy_powerdown5,
  output [2:0]    phy_powerdown6,
  output [2:0]    phy_powerdown7,
  output [2:0]    phy_powerdown8,
  output [2:0]    phy_powerdown9,
  output [2:0]    phy_powerdown10,
  output [2:0]    phy_powerdown11,
  output [2:0]    phy_powerdown12,
  output [2:0]    phy_powerdown13,
  output [2:0]    phy_powerdown14,
  output [2:0]    phy_powerdown15,
  output [15:0]   phy_rate,
  output [15:0]   phy_txdeemph,
  output [2:0]    phy_txmargin0,
  output [2:0]    phy_txmargin1,
  output [2:0]    phy_txmargin2,
  output [2:0]    phy_txmargin3,
  output [2:0]    phy_txmargin4,
  output [2:0]    phy_txmargin5,
  output [2:0]    phy_txmargin6,
  output [2:0]    phy_txmargin7,
  output [2:0]    phy_txmargin8,
  output [2:0]    phy_txmargin9,
  output [2:0]    phy_txmargin10,
  output [2:0]    phy_txmargin11,
  output [2:0]    phy_txmargin12,
  output [2:0]    phy_txmargin13,
  output [2:0]    phy_txmargin14,
  output [2:0]    phy_txmargin15,
  output [15:0]   phy_txswing,
  input [15:0]    phy_rxvalid,
  input [15:0]    phy_phystatus,
  input [15:0]    phy_rxelecidle,
  input [2:0]     phy_rxstatus0,
  input [2:0]     phy_rxstatus1,
  input [2:0]     phy_rxstatus2,
  input [2:0]     phy_rxstatus3,
  input [2:0]     phy_rxstatus4,
  input [2:0]     phy_rxstatus5,
  input [2:0]     phy_rxstatus6,
  input [2:0]     phy_rxstatus7,
  input [2:0]     phy_rxstatus8,
  input [2:0]     phy_rxstatus9,
  input [2:0]     phy_rxstatus10,
  input [2:0]     phy_rxstatus11,
  input [2:0]     phy_rxstatus12,
  input [2:0]     phy_rxstatus13,
  input [2:0]     phy_rxstatus14,
  input [2:0]     phy_rxstatus15,
  input           phy_pclk);
  
  //----------------------------------------------------------------------------
  // Pass-Through Assignments: Inputs from MAC (PIPE MAC) Interface are 
  //   copied to Outputs on PHY (PIPE PHY) Interface, and vice versa
  //----------------------------------------------------------------------------
  assign phy_lane0_rxdata      =   mac_lane0_txdata;    
  assign phy_lane0_rxdatak     =   mac_lane0_txdatak;
  assign mac_lane0_rxdata      =   phy_lane0_txdata;
  assign mac_lane0_rxdatak     =   phy_lane0_txdatak;
  
  assign phy_lane1_rxdata      =   mac_lane1_txdata;
  assign phy_lane1_rxdatak     =   mac_lane1_txdatak;
  assign mac_lane1_rxdata      =   phy_lane1_txdata;
  assign mac_lane1_rxdatak     =   phy_lane1_txdatak;
  
  assign phy_lane2_rxdata      =   mac_lane2_txdata;
  assign phy_lane2_rxdatak     =   mac_lane2_txdatak;
  assign mac_lane2_rxdata      =   phy_lane2_txdata;
  assign mac_lane2_rxdatak     =   phy_lane2_txdatak;
  
  assign phy_lane3_rxdata      =   mac_lane3_txdata;
  assign phy_lane3_rxdatak     =   mac_lane3_txdatak;
  assign mac_lane3_rxdata      =   phy_lane3_txdata;
  assign mac_lane3_rxdatak     =   phy_lane3_txdatak;
  
  assign phy_lane4_rxdata      =   mac_lane4_txdata;
  assign phy_lane4_rxdatak     =   mac_lane4_txdatak;
  assign mac_lane4_rxdata      =   phy_lane4_txdata;
  assign mac_lane4_rxdatak     =   phy_lane4_txdatak;
  
  assign phy_lane5_rxdata      =   mac_lane5_txdata;
  assign phy_lane5_rxdatak     =   mac_lane5_txdatak;
  assign mac_lane5_rxdata      =   phy_lane5_txdata;
  assign mac_lane5_rxdatak     =   phy_lane5_txdatak;
  
  assign phy_lane6_rxdata      =   mac_lane6_txdata;
  assign phy_lane6_rxdatak     =   mac_lane6_txdatak;
  assign mac_lane6_rxdata      =   phy_lane6_txdata;
  assign mac_lane6_rxdatak     =   phy_lane6_txdatak;
  
  assign phy_lane7_rxdata      =   mac_lane7_txdata;
  assign phy_lane7_rxdatak     =   mac_lane7_txdatak;
  assign mac_lane7_rxdata      =   phy_lane7_txdata;
  assign mac_lane7_rxdatak     =   phy_lane7_txdatak;
  
  assign phy_lane8_rxdata      =   mac_lane8_txdata;
  assign phy_lane8_rxdatak     =   mac_lane8_txdatak;
  assign mac_lane8_rxdata      =   phy_lane8_txdata;
  assign mac_lane8_rxdatak     =   phy_lane8_txdatak;
  
  assign phy_lane9_rxdata      =   mac_lane9_txdata;
  assign phy_lane9_rxdatak     =   mac_lane9_txdatak;
  assign mac_lane9_rxdata      =   phy_lane9_txdata;
  assign mac_lane9_rxdatak     =   phy_lane9_txdatak;
  
  assign phy_lane10_rxdata     =   mac_lane10_txdata;
  assign phy_lane10_rxdatak    =   mac_lane10_txdatak;
  assign mac_lane10_rxdata     =   phy_lane10_txdata;
  assign mac_lane10_rxdatak    =   phy_lane10_txdatak;
  
  assign phy_lane11_rxdata     =   mac_lane11_txdata;
  assign phy_lane11_rxdatak    =   mac_lane11_txdatak;
  assign mac_lane11_rxdata     =   phy_lane11_txdata;
  assign mac_lane11_rxdatak    =   phy_lane11_txdatak;
  
  assign phy_lane12_rxdata     =   mac_lane12_txdata;
  assign phy_lane12_rxdatak    =   mac_lane12_txdatak;
  assign mac_lane12_rxdata     =   phy_lane12_txdata;
  assign mac_lane12_rxdatak    =   phy_lane12_txdatak;
  
  assign phy_lane13_rxdata     =   mac_lane13_txdata;
  assign phy_lane13_rxdatak    =   mac_lane13_txdatak;
  assign mac_lane13_rxdata     =   phy_lane13_txdata;
  assign mac_lane13_rxdatak    =   phy_lane13_txdatak;
  
  assign phy_lane14_rxdata     =   mac_lane14_txdata;
  assign phy_lane14_rxdatak    =   mac_lane14_txdatak;
  assign mac_lane14_rxdata     =   phy_lane14_txdata;
  assign mac_lane14_rxdatak    =   phy_lane14_txdatak;
  
  assign phy_lane15_rxdata     =   mac_lane15_txdata;
  assign phy_lane15_rxdatak    =   mac_lane15_txdatak;
  assign mac_lane15_rxdata     =   phy_lane15_txdata;
  assign mac_lane15_rxdatak    =   phy_lane15_txdatak;

  assign phy_txdetectrx        =  mac_txdetectrx;  
  assign phy_txelecidle        =  mac_txelecidle;
  assign phy_txcompliance      =  mac_txcompliance;
  assign phy_rxpolarity        =  mac_rxpolarity;
  assign phy_reset_n           =  mac_reset_n;
  assign phy_powerdown0        =  mac_powerdown0;
  assign phy_powerdown1        =  mac_powerdown1;
  assign phy_powerdown2        =  mac_powerdown2;
  assign phy_powerdown3        =  mac_powerdown3;
  assign phy_powerdown4        =  mac_powerdown4;
  assign phy_powerdown5        =  mac_powerdown5;
  assign phy_powerdown6        =  mac_powerdown6;
  assign phy_powerdown7        =  mac_powerdown7;
  assign phy_powerdown8        =  mac_powerdown8;
  assign phy_powerdown9        =  mac_powerdown9;
  assign phy_powerdown10       =  mac_powerdown10;
  assign phy_powerdown11       =  mac_powerdown11;
  assign phy_powerdown12       =  mac_powerdown12;
  assign phy_powerdown13       =  mac_powerdown13;
  assign phy_powerdown14       =  mac_powerdown14;
  assign phy_powerdown15       =  mac_powerdown15;
  assign phy_rate              =  mac_rate;
  assign phy_txdeemph          =  mac_txdeemph;
  assign phy_txmargin0         =  mac_txmargin0;
  assign phy_txmargin1         =  mac_txmargin1;
  assign phy_txmargin2         =  mac_txmargin2;
  assign phy_txmargin3         =  mac_txmargin3;
  assign phy_txmargin4         =  mac_txmargin4;
  assign phy_txmargin5         =  mac_txmargin5;
  assign phy_txmargin6         =  mac_txmargin6;
  assign phy_txmargin7         =  mac_txmargin7;
  assign phy_txmargin8         =  mac_txmargin8;
  assign phy_txmargin9         =  mac_txmargin9;
  assign phy_txmargin10        =  mac_txmargin10;
  assign phy_txmargin11        =  mac_txmargin11;
  assign phy_txmargin12        =  mac_txmargin12;
  assign phy_txmargin13        =  mac_txmargin13;
  assign phy_txmargin14        =  mac_txmargin14;
  assign phy_txmargin15        =  mac_txmargin15;
  assign phy_txswing           =  mac_txswing;
  
  assign mac_rxvalid           =  phy_rxvalid ;         
  assign mac_phystatus         =  phy_phystatus;        
  assign mac_rxelecidle        =  phy_rxelecidle;       
  assign mac_rxstatus0         =  phy_rxstatus0;        
  assign mac_rxstatus1         =  phy_rxstatus1;       
  assign mac_rxstatus2         =  phy_rxstatus2;        
  assign mac_rxstatus3         =  phy_rxstatus3;        
  assign mac_rxstatus4         =  phy_rxstatus4;        
  assign mac_rxstatus5         =  phy_rxstatus5;        
  assign mac_rxstatus6         =  phy_rxstatus6;        
  assign mac_rxstatus7         =  phy_rxstatus7;        
  assign mac_rxstatus8         =  phy_rxstatus8;        
  assign mac_rxstatus9         =  phy_rxstatus9;        
  assign mac_rxstatus10        =  phy_rxstatus10;       
  assign mac_rxstatus11        =  phy_rxstatus11;       
  assign mac_rxstatus12        =  phy_rxstatus12;       
  assign mac_rxstatus13        =  phy_rxstatus13;       
  assign mac_rxstatus14        =  phy_rxstatus14;       
  assign mac_rxstatus15        =  phy_rxstatus15;
  assign mac_pclk              =  phy_pclk;

endmodule

//==============================================================================
`endif
