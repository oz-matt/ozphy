#!/bin/sh
rm -rf output logs coverage;
mkdir output logs coverage;
vcs -lca -debug_all -l ./logs/compile.log -q -Mdir=./output/csrc +warn=noBCNACMBP -full64 \
-sverilog +define+WAVES="dve" +plusarg_save +vpdports -I -notice +define+SYNOPSYS_SV \
-ntb_define NTB -ntb_opts rvm -ntb_opts use_sigprop -ntb_opts dw_vip -ntb_vipext \
.ov +define+NTB -ntb_incdir /home/iclab608/vipe/include/vera+/home/iclab608/vipe/src/vera+/home/iclab608/vipe/../ozphy/env+/home/iclab608/vipe/../ozphy/hdl_interconnect \
+incdir+/home/iclab608/vipe/include/verilog +incdir+/home/iclab608/vipe/include/svtb \
+incdir+/home/iclab608/vipe/include/sverilog +incdir+/home/iclab608/vipe/src/sverilog/vcs \
+incdir+/home/iclab608/vipe/../ozphy/../env +incdir+/home/iclab608/vipe/../ozphy/env \
+incdir+/home/iclab608/vipe/../ozphy/dut +incdir+/home/iclab608/vipe/../ozphy/hdl_interconnect \
+incdir+/home/iclab608/vipe/../ozphy/tests -o ./output/simvcssvtb +pkgdir+/home/iclab608/vipe/include/svtb \
-f hdl_files2
./output/simvcssvtb   +rad +v2k +prof -l ./logs/simulate.log run -assert dumpoff +vpdfile+vpdplus.vpd -vcd vcdplus.vcd -gui

