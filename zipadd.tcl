#!tclsh8.0
if {$argc<2} { error "usage zipadd.tcl <zipfile> <dirname>" }
set zipFile [lindex $argv 0]
set dir     [lindex $argv 1]
#puts stderr "zipfile is  $zipFile, dir is $dir"
if {$dir=="" || $dir=="." || $dir ==".\\" || $dir=="./"} {
    error "wrong directory name \"$dir\""
}
proc mk_bs { str } {
  regsub -all "/" $str "\\" a
  return $a
}

global zlist 
set zlist ""
                                                                                
proc ziplist { dirlong dir } {
  if {[catch "cd $dir" msg]} {
    puts stderr "could not cd to $dir:$msg"
    return ""
  }
  if {[catch {glob *} dirlist]} {
    cd ..
    return ""
  }
  foreach i $dirlist {
    if {[file isdir $i]} {
      if {$i != "CVS" } {
         ziplist [file join $dir $i] $i
      }
    } else {
      set dirpath [file join $dirlong $i]
      set dirpath [mk_bs $dirpath]
      #puts stderr "adding name $dirpath"
      global zlist
      lappend zlist $dirpath
    }
  }
  cd ..
}
ziplist $dir $dir
foreach i $zlist {
#  puts stderr "  adding: $i"
  if {[catch {exec zip.exe $zipFile $i} msg]} {
    puts stderr "Could not add $i to $zipFile:$msg"
  } else {
      puts $msg
  }
}

