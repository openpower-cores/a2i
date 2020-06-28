# create/build project

```
$VIVADO -mode tcl -source create_a2x_project.tcl

$VIVADO proj/proj_a2x_axi.xpr

source ./fixup_a2x_bd.tcl

>run synthesis (synth_2)
>open synthesized design

source ./ila_axi.tcl
>set up debug 
>   all clk
>   8192/3 

source ./a2x_impl_step.tcl
```

```
a2x_axi_routed_v0.dcp
a2x_axi_synth_v0.dcp
a2x_axi_v0.bin
a2x_axi_v0.bit
a2x_axi_v0.ltx
a2x_axi_v0_primary.bin
a2x_axi_v0_primary.prm
a2x_axi_v0_secondary.bin
a2x_axi_v0_secondary.prm
```
