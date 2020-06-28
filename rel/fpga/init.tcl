# init.tcl
#

set TCL [file dirname [info script]] 

proc include {f} {
   global TCL
   source -notrace [file join $TCL $f]
}

include "utils.tcl"
include "waimea.tcl"

