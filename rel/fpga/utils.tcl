# utils.tcl
#

proc timestamp {{t ""}} {
   if {$t == ""} {
      set t [clock seconds]
   }
   return [clock format $t -format %y%m%d%H%M%S]
}

proc datetime {{t ""}} {
   if {$t == ""} {
      set t [clock seconds]
   }
   return [clock format $t -format "%m-%d-%y %I:%M:%S %p %Z"]
}

proc now {} {
   return [clock seconds]
}

proc vivado_year {} {
   regexp -- {Vivado v(\d\d\d\d)\.*} [version] s year
   return $year
}


