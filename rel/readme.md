## Directory Structure

```
src/vhdl
   clib (low-level components)
   ibm (std_ulogic)
   support (power_logic subtype)
   tri (latches and arrays)
   work (macros)
```

```
build
   a2x (project)
   ip_cache (empty until project built)
   ip_repo (empty until IP built/copied)
   ip_user (IP macros to be built)
   tcl (build scripts)
   xdc (constraints)
```

```
fpga
   tcl 
```

```
doc
   core user guide, etc.
```


## Build Process

### IP

IP is created in ip_user and copied to ip_repo for use in top level bd.

See build/ip_user/xxx/readme.md.

Core:

```
a2x_axi
```

Simple card components:

```
a2x_axi_reg 
a2x_dbug
a2x_reset 
```

Help Vivado attach to VIO correctly:

```
reverserator_3
reverserator_4
reverserator_32
reverserator_64
```

### Project

See build/a2x/readme.md.

1. create project
2. synth/implement

