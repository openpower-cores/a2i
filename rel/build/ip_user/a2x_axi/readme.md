# create IP: a2x_axi 

```
$VIVADO -mode tcl -source tcl/create_ip_a2x_axi.tcl
rm -r ../../ip_repo/a2x_axi
cp -r a2x_axi ../../ip_repo
```

