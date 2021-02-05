//=======================================================================
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
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
// Abstract:
//    Top level SystemVerilog testbench
//
// Notes:
//    PHY (Test Bench Device) - PcieTxrx representing the testbench (PIPE PHY interface)
//    MAC (Device Under Test) - PcieTxrx representing the MAC (PIPE MAC interface)
//    MON (Monitor)           - PcieMonitor tracking the MAC
//


`include "pcie_basic_hdl_interconnect_sv_wrapper.sv"
`include "top_prog.sv"
module test_top;
//-----------------------------------------------------------------------
// Define clock period for system clock. It is set to 4 ns (400*10 ps (Time unit))
// to represent 250 MHz clock expected by PCI Express VIP operating in GEN1 mode.
//-----------------------------------------------------------------------
	parameter simulation_cycle = 400;

//-----------------------------------------------------------------------
// Declare system clock register.
//-----------------------------------------------------------------------
	reg SystemClock;

	wire [9:0] b10out;

	pcie_basic_if pcie_mac_if ();
	pcie_basic_if pcie_phy_if ();
	pcie_basic_hdl_interconnect_sv_wrapper hdl_interconnect(pcie_mac_if, pcie_phy_if);

	ozphy ozp_i(pcie_phy_if, b10out);

	initial
	begin
		SystemClock = 0;
		#(simulation_cycle);
		forever
			#(simulation_cycle/2) SystemClock = ~SystemClock;
	end

	initial begin

		top_prog env ;
		env = new("PCI Express Env", pcie_mac_if.TxRx, pcie_phy_if.TxRx, pcie_mac_if.Monitor );
		env.start();
		env.atomic_tlp_gen.stop_xactor();
		env.do_directed_test(env.atomic_tlp_gen, env.log);
	end

	assign pcie_mac_if.clk = SystemClock;
	assign pcie_phy_if.clk = SystemClock;

	initial begin
		#4000000;
		$display("yogiiiiiiiiii");
		$finish();
	end

`ifdef WAVES
	initial
	begin
		string wave_str = "`WAVES";
		if (!wave_str.compare("virsim") || !wave_str.compare("vcd"))
			$dumpvars;
		else
			// The vcdplus format is much more compact, but it is only available in
			// VCS and VCS-MX. Testbenches which are run in other Verilog environments
			// must at a minimum comment out or remove the following line.
			// They may wish to replace this entire block with a simple '$dumpvars' call.
			$vcdpluson;
	end
`endif

endmodule

//=======================================================================
