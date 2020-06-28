# board/core command interface

####################################################################
# system commands 

proc reset {} {

   set filter "CELL_NAME=~\"*vio_ctrl*\""
   set probe "marvio_probe_out1"

   set obj_vio [get_hw_vios -of_objects [get_hw_devices xcvu3p_0] -filter $filter]
   set rst [get_hw_probes a2x_axi_bd_i/vio_0_probe_out1 -of_objects $obj_vio]
   startgroup
   set_property OUTPUT_VALUE 0 $rst
   commit_hw_vio $rst
   endgroup
   startgroup
   set_property OUTPUT_VALUE 1 $rst
   commit_hw_vio $rst
   endgroup
   puts "[datetime] Reset"
}

proc threadstop {{val F}} {

   set filter "CELL_NAME=~\"*vio_ctrl*\""
   set probe "marvio_probe_out0"

   set obj_vio [get_hw_vios -of_objects [get_hw_devices xcvu3p_0] -filter $filter]
   set thread_stop [get_hw_probes a2x_axi_bd_i/$probe -of_objects $obj_vio]
   set_property OUTPUT_VALUE $val $thread_stop
   commit_hw_vio $thread_stop
   puts "[datetime] ThreadStop=$val"
}

####################################################################
# ila commands

proc ila_arm {{n 0}} {
  set filter "CELL_NAME=~\"u_ila_$n\""
  set res [run_hw_ila [get_hw_ilas -of_objects [get_hw_devices xcvu3p_0] -filter $filter]]
  puts "[datetime] ILA$n armed."
}

proc ila_wait {{n 0}} {
  set filter "CELL_NAME=~\"u_ila_$n\""
  puts "[datetime] ILA$n waiting..."
  set res [wait_on_hw_ila [get_hw_ilas -of_objects [get_hw_devices xcvu3p_0] -filter $filter]]
  display_hw_ila_data [upload_hw_ila_data [get_hw_ilas -of_objects [get_hw_devices xcvu3p_0] -filter $filter]]
  puts "[datetime] ILA$n triggered."
}

####################################################################
# axi slave commands

proc raxi {addr {len 8} {dev 0} {width 8}} {

  if {$dev == 0} {
    set dev [get_hw_axis hw_axi_1]
  }

  create_hw_axi_txn -f raxi_txn $dev -address $addr -len $len -type read
  run_hw_axi -quiet raxi_txn
  set res [report_hw_axi_txn -w $width raxi_txn]
  return $res 

}

proc waxi {addr data {len 8} {dev 0}} {

  if {$dev == 0} {
    set dev [get_hw_axis hw_axi_1]
  }

  create_hw_axi_txn -f waxi_txn $dev -address $addr -len $len -type write -data $data
  run_hw_axi -quiet waxi_txn
  set res [report_hw_axi_txn waxi_txn]
  return $res 

}

proc waxiq {addr data {len 8} {dev 0}} {

  set res [waxi $addr $data $len $dev]

}

proc testwrites {addr xfers} {

  set start [datetime]
  for {set i 0} {$i < $xfers} {incr i} {
    waxi $addr 00000000_11111111_22222222_33333333_44444444_55555555_66666666_77777777
  }
  set end [datetime]

  puts "Finished $xfers 32B writes."
  puts "Start: $start"
  puts "  End: $end"

}

proc testwrites_128B {addr xfers} {

  set start [datetime]
  for {set i 0} {$i < $xfers} {incr i} {
    waxi $addr {
         00000000 00000001 00000002 00000003 00000004 00000005 00000006 00000007
         00000008 00000009 0000000A 0000000B 0000000C 0000000D 0000000E 0000000F
         00000010 00000011 00000012 00000013 00000014 00000015 00000006 00000017
         00000018 00000019 0000001A 0000001B 0000001C 0000001D 0000000E 0000001F
               } 32
  }
  set end [datetime]

  puts "Finished $xfers 122B writes."
  puts "Start: $start"
  puts "  End: $end"

}

proc map {lambda list} {
  set res {}
  foreach i $list {
     lappend res [apply $lambda $i]
  }
  return $res
}

proc bytereverse {x} {
   set res ""
   for {set i 0} {$i < [string length $x]} {incr i 2} {
     set res "[string range $x $i [expr $i+1]]$res"
   }
   return $res
}

proc ascii {start {len 32} {dev 0}} {
  set w 128
  set res ""
  set count [expr ($len-1)/$w + 1]
  set ptr $start

  for {set i 0} {$i < $count} {incr i} {

    set mem [raxi $ptr [expr $w/4] $dev $w]
    set ptr [format %x [expr [expr 0x$ptr] + $w]]

    # split and remove addr
    set tokens [regexp -all -inline {\S+} $mem]
    set tokens [lrange $tokens 1 end]

    # bytereverse and ascii
    set tokens [map {x {return [bytereverse $x]}} $tokens]
    set bytes [join $tokens {}]
    set chars [binary format H* $bytes]

    set res "$res$chars"

  }
  return $res
}


