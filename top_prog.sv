
`include "VmtDefines.inc"
`include "PcieDefines.inc"

import PcieTxrx_rvm::* ;
import PcieMonitor_rvm::* ;

`define SIM_TIMEOUT_IN_CYCLES    500_000
`define MEM_END_ADDR             64'hFFFFFFFFFFFFFFFC

`define PHY_REQ_ID               16'h0100
`define PHY_CPL_ID               16'h0100

`define MAC_REQ_ID               16'h0210
`define MAC_CPL_ID               16'h0210
`define MAC2_REQ_ID               16'h0100
`define MAC2_CPL_ID               16'h0100
`define ENABLE_LOGGING           1


`include "pcie_basic_if.sv"
`include "pcie_basic_cust_tlp_transaction.sv"

`include "ozphy.sv"

`vmm_atomic_gen (dw_vip_pcie_tlp_transaction,"PCI Express TLP Atomic Gen")

class top_prog;

	virtual pcie_basic_if.TxRx                         vip_port_mac;
	virtual pcie_basic_if.TxRx                         vip_port_phy;
	virtual pcie_basic_if.Monitor                      vip_port_monitor;
	virtual pcie_basic_if.TxRx                         vip_port_mac2;
	virtual pcie_basic_if.TxRx                         vip_port_phy2;

	/* The built-in log object */
	static vmm_log   log = new("pcie_basic_env", "class");
	dw_vip_pcie_txrx_rvm                               vip_mac;
	dw_vip_pcie_txrx_rvm                               vip_mac2;
	dw_vip_pcie_txrx_rvm                               vip_phy;
	dw_vip_pcie_monitor_rvm                            vip_monitor;

	/* Declare configuration objects for each environment component. */
	dw_vip_pcie_configuration                          mac_cfg;
	dw_vip_pcie_configuration                          mac_cfg2;
	dw_vip_pcie_configuration                          phy_cfg;
	dw_vip_pcie_configuration                          mon_cfg;

	dw_vip_pcie_tlp_transaction_atomic_gen             atomic_tlp_gen;
	event                                              timeout_event;
	integer                                            expected_tlp_xact_cnt = 24;
	integer                                            tx_tlp_xact_cnt = 0;
	dw_vip_pcie_tlp_transaction                        last_tlp_xact;

	function new( string name = "PCIe Env",
			virtual pcie_basic_if.TxRx     vip_port_mac,
			virtual pcie_basic_if.TxRx     vip_port_phy,
			virtual pcie_basic_if.Monitor  vip_port_monitor,
			virtual pcie_basic_if.TxRx     vip_port_mac2,
			virtual pcie_basic_if.TxRx     vip_port_phy2
		) ;
		begin
			this.vip_port_mac2                = vip_port_mac2;
			this.vip_port_phy2                = vip_port_phy2;
			this.vip_port_mac                = vip_port_mac;
			this.vip_port_phy                = vip_port_phy;
			this.vip_port_monitor            = vip_port_monitor;
		end
	endfunction : new


	virtual task start() ;
		begin

			this.mac_cfg                               = new ();
			this.mac_cfg.m_enPosition                  = dw_vip_pcie_configuration::UPSTREAM;

			this.mac_cfg.m_enInterfaceType             = dw_vip_pcie_configuration::MAC_PIPE8;

			this.mac_cfg.m_bSupport2Lanes              = Vmt::VMT_BOOLEAN_TRUE;

			this.mac_cfg.m_bScrambling                 = Vmt::VMT_BOOLEAN_FALSE;

			this.mac_cfg.m_enInitialLtssmState         = dw_vip_pcie_configuration::DETECT;
			this.mac_cfg.m_bLtssmFastTimeouts          = Vmt::VMT_BOOLEAN_TRUE;
			this.mac_cfg.m_nPipeDetectRcvrTime         = 10;
			//this.mac_cfg.m_nPhyPipePollingEntryDelay   = 10;
			this.mac_cfg.m_bBypassFcInit               = Vmt::VMT_BOOLEAN_FALSE;
			this.mac_cfg.m_bvReqId                     = `MAC_REQ_ID;
			this.mac_cfg.m_bvCplId                     = `MAC_CPL_ID;
			this.mac_cfg.m_nNumMemCplAddrRanges        = 1;
			this.mac_cfg.m_bvMemCplStartAddr[0]        = 0;
			this.mac_cfg.m_bvMemCplEndAddr[0]          = `MEM_END_ADDR;
			this.mac_cfg.m_nNumIoCplAddrRanges         = 1;

			this.mac_cfg.m_nMaxPayloadSize             = 128;
			
			
			
			

			this.mac_cfg2                               = new ();
			this.mac_cfg2.m_enPosition                  = dw_vip_pcie_configuration::DOWNSTREAM;

			this.mac_cfg2.m_enInterfaceType             = dw_vip_pcie_configuration::MAC_PIPE8;

			this.mac_cfg2.m_bSupport2Lanes              = Vmt::VMT_BOOLEAN_TRUE;

			this.mac_cfg2.m_bScrambling                 = Vmt::VMT_BOOLEAN_FALSE;

			this.mac_cfg2.m_enInitialLtssmState         = dw_vip_pcie_configuration::DETECT;
			this.mac_cfg2.m_bLtssmFastTimeouts          = Vmt::VMT_BOOLEAN_TRUE;
			this.mac_cfg2.m_nPipeDetectRcvrTime         = 10;
			//this.mac_cfg.m_nPhyPipePollingEntryDelay   = 10;
			this.mac_cfg2.m_bBypassFcInit               = Vmt::VMT_BOOLEAN_FALSE;
			this.mac_cfg2.m_bvReqId                     = `MAC2_REQ_ID;
			this.mac_cfg2.m_bvCplId                     = `MAC2_CPL_ID;
			this.mac_cfg2.m_nNumMemCplAddrRanges        = 1;
			this.mac_cfg2.m_bvMemCplStartAddr[0]        = 0;
			this.mac_cfg2.m_bvMemCplEndAddr[0]          = `MEM_END_ADDR;
			this.mac_cfg2.m_nNumIoCplAddrRanges         = 1;

			this.mac_cfg2.m_nMaxPayloadSize             = 128;
			
			
			
			
			
			$cast(this.phy_cfg, this.mac_cfg.copy());
			this.phy_cfg.m_nPhyPipePollingEntryDelay   = 10;
			this.phy_cfg.m_enPosition                  = dw_vip_pcie_configuration::DOWNSTREAM;
			this.phy_cfg.m_enInterfaceType             = dw_vip_pcie_configuration::PHY_PIPE8;
			this.phy_cfg.m_bvReqId                     = `PHY_REQ_ID;
			this.phy_cfg.m_bvCplId                     = `PHY_CPL_ID;

			$cast(this.mon_cfg, this.phy_cfg.copy());

			this.phy_cfg.display("PHY_CFG::");
			this.mac_cfg.display("MAC_CFG::");
			this.mon_cfg.display("MON_CFG::");
			atomic_tlp_gen  = new ("PCI Express PHY Gen", 0);

			/*vip_phy  = new ("PCI EXPRESS PHY",
			 this.vip_port_phy ,
			 this.phy_cfg);
			 */

			vip_mac  = new ("PCI EXPRESS MAC",
				this.vip_port_mac,
				this.mac_cfg,
				atomic_tlp_gen.out_chan);

			vip_mac2  = new ("PCI EXPRESS MAC",
				this.vip_port_mac2,
				this.mac_cfg2);

			vip_monitor  = new ("PCI EXPRESS MONITOR",
				this.vip_port_monitor,
				this.mon_cfg);
			vip_monitor.log.modify(,,,,vmm_log::ERROR_SEV,
				"/Detected 7 symbols of skew/",,
				vmm_log::WARNING_SEV, vmm_log::CONTINUE);

			vip_monitor.log.modify(,,,,vmm_log::WARNING_SEV,
				"/packet has invalid sequence number/",,
				vmm_log::NORMAL_SEV, vmm_log::CONTINUE);

			vip_monitor.log.set_verbosity(vmm_log::WARNING_SEV);
			//vip_phy.start_xactor();
			vip_mac.start_xactor();
			vip_mac2.start_xactor();
			vip_monitor.start_xactor();

			vip_monitor.open_symbol_log("./pcie_basic_sys_symbol.log", "w");

			vip_monitor.open_transaction_log("./pcie_basic_sys_transaction.log", "w");

			atomic_tlp_gen.start_xactor();
		end
	endtask : start

	task do_directed_test (dw_vip_pcie_tlp_transaction_atomic_gen atomic_tlp_gen, vmm_log log) ;
		begin
			integer i;

			bit dropped = 1'b0;
			dw_vip_pcie_tlp_transaction tlp_xacts[2];
			tlp_xacts[0]                      = new;
			tlp_xacts[0].m_enType             = dw_vip_pcie_tlp_transaction::MEM_WR_32;
			tlp_xacts[0].m_bvRequesterId      = `PHY_REQ_ID;
			tlp_xacts[0].m_bvLastDWBE         = 4'b1111;
			tlp_xacts[0].m_bvFirstDWBE        = 4'b1111;
			tlp_xacts[0].m_bvLength           = 4;
			tlp_xacts[0].m_bvPayloadSize      = 4;
			tlp_xacts[0].m_bvAddr             = 32'h10000000;

			for (i=0; i < tlp_xacts[0].m_bvLength; i++)
			begin
				tlp_xacts[0].m_bvvPayload[i]    = $random;
			end

			tlp_xacts[1]                      = new;
			tlp_xacts[1].m_enType             = dw_vip_pcie_tlp_transaction::MEM_RD_32;
			tlp_xacts[1].m_bvRequesterId      = `PHY_REQ_ID;
			tlp_xacts[1].m_bvLastDWBE         = 4'b0011;
			tlp_xacts[1].m_bvFirstDWBE        = 4'b1100;
			tlp_xacts[1].m_bvLength           = 4;
			tlp_xacts[1].m_bvAddr             = 32'h10000000;

			atomic_tlp_gen.inject(tlp_xacts[0], dropped);

			tlp_xacts[0].notify.wait_for(vmm_data::ENDED);
			if (log.get_verbosity() >= vmm_log::DEBUG_SEV)
			begin
				tlp_xacts[0].display($psprintf("PHY TX TLP: "));
			end


			atomic_tlp_gen.inject(tlp_xacts[1], dropped);

			tlp_xacts[1].notify.wait_for(vmm_data::ENDED);


			if (log.get_verbosity() >= vmm_log::DEBUG_SEV)
			begin
				tlp_xacts[1].display($psprintf("PHY TX TLP: "));
			end
		end
	endtask : do_directed_test
endclass

