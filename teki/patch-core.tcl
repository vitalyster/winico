#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}


if {$tcl_version < 8.0} {
    puts stderr "Requires Tcl 8.0 or later"
    exit
}
puts stderr "Adding teki.tcl to [info library]"

set tekiFileName [file join [info library] teki.tcl]
set f [open $tekiFileName w]
puts $f {
#
# Support procedures for all extensions.  The following two procedures
# are used at runtime to source/load the right files (including architecture
# dependent files).  TekiPackageInit is called by the pkgIndex.tcl file
# with the package name, after the tclPkgInfo variables have been set up.
# It determines if the OS is supported, and if so, makes the right calls
# to package ifneeded.  TekiPackageSetup is called when package require
# is called.  It loads all the files (including architecture dependent
# files
#
proc TekiPackageInit {pkg} {
    global tclPkgInfo tcl_platform

    set os $tcl_platform(os)
    set ver $tcl_platform(osVersion)

    set system {}
    foreach tuple $tclPkgInfo($pkg,systemNames) {
        set osPattern [lindex $tuple 1]
        set verPattern [lindex $tuple 2]
        if {[string match $osPattern $os] &&
            [string match $verPattern $ver]} {
            set system [lindex $tuple 0]
            break;
        }
    }
    if [string length $system] {
        set name $tclPkgInfo($pkg,name)
        set version $tclPkgInfo($pkg,version) 
        package ifneeded $name $version "TekiPackageSetup $pkg $system"
    }
}

proc TekiPackageSetup {pkg system} {
    global tclPkgInfo
    set currDir [pwd]
    set prefix $tclPkgInfo($pkg,codePrefix)
    set destDir [file join $prefix $tclPkgInfo($pkg,destDir)]
    cd $destDir
    set tclFiles $tclPkgInfo($pkg,tclFiles)
    if [info exists tclPkgInfo($pkg,objFiles,$system)] {
        set objFiles $tclPkgInfo($pkg,objFiles,$system)
    } else {
        set objFiles {}
    }
    foreach f $tclFiles {
        catch {uplevel #0 "source $f"}
    }
    foreach f $objFiles {
        if [string match *.tcl $f] {
            catch {uplevel #0 "source $f"}
        } else {
            catch {uplevel #0 "load $f"}
        }
    }
    cd $currDir
}
}
close $f
puts stderr "Running auto_mkindex [info library]"
auto_mkindex [info library]
puts stderr done
