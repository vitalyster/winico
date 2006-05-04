# trayapp.tcl - Copyright (C) 2006 Pat Thoyts <patthoyts@users.sourceforge.net>
# 
# Demonstration of a Tk application that exists primarily in the system 
# tray. Click on the icon to show the GUI and click again to hide it.
#
# $Id$

package require Tk
package require Winico

namespace eval Demo {
    variable IconFile {}
}

proc ::Demo::WinicoInit {toplevel} {
    if {[tk windowingsystem] eq "win32" && ![catch {package require Winico}]} {
        variable TaskbarIcon
        variable IconFile
        variable WinicoWmState [wm state $toplevel]
        
        if {[file exists $IconFile]} {
            set TaskbarIcon [winico createfrom $IconFile]
        } else {
            set TaskbarIcon [winico load exclamation]
        }
        winico taskbar add $TaskbarIcon \
            -pos 0 \
            -text [wm title $toplevel] \
            -callback [list [namespace origin WinicoCallback] $toplevel %m %i]
        bind $toplevel <Destroy> [namespace origin WinicoCleanup]
    }
}

proc ::Demo::WinicoCleanup {} {
    variable TaskbarIcon
    winico taskbar delete $TaskbarIcon
}

proc ::Demo::WinicoCallback {toplevel msg icn} {
    variable WinicoWmState
    switch -exact -- $msg {
        WM_LBUTTONDOWN {
            if { [wm state $toplevel] eq "withdrawn" } {
                wm state $toplevel $WinicoWmState
                wm deiconify $toplevel
            } else {
                set WinicoWmState [wm state $toplevel]
                wm withdraw $toplevel
            }
        }
    }
}

proc ::Demo::Main {} {
    # If we want to start hidden, uncomment the next line.
    # wm withdraw .
    wm title . "Winico Minimization Demo"
    pack [label .l0 -text "Demonstration of a system tray application."]
    pack [label .l1 -text "Click on the exclamation icon to show/hide this window"]
    pack [button .b -width -12 -text Exit -command {set ::forever 1}]
    WinicoInit .
    bind . <Control-F2> {console show}
    set ::forever 0
    tkwait variable ::forever
}

if {!$tcl_interactive} {
    set r [catch [linsert $argv 0 ::Demo::Main] err]
    if {$r} { tk_messageBox -icon error -message $err }
    exit
}
