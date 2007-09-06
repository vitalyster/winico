# teatimer.tcl - Copyright (C) 2005 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# Winico package demo
#
#
# $Id$

package require Tk 8.4
package require Winico 0.6

# -------------------------------------------------------------------------

namespace eval TeaTimer {
    variable rcsid {$Id$}
    variable uid; if {![info exists uid]} { set uid 0 }
}

proc TeaTimer::Main {mainwindow} {
    variable uid
    set Application [namespace current]::App[incr uid]
    upvar #0 $Application App
    array set App [list run 0 dlg 0 mw $mainwindow \
                       timerid {} faderid {} \
                       text "Tea timer" \
                       message "Do your excercises" \
                       interval 1800 \
                       alarm 0]

    wm title $App(mw) $App(text)
    wm withdraw $App(mw)

    # Load an icon file with multiple icons or default to a system icon.
    set icofile [file join [file dirname [info script]] tkchat.ico]
    if {[file exists $icofile]} {
        set App(icon) [winico createfrom $icofile]
    } else {
        set App(icon) [winico load exclamation]
    }

    # Create a context menu to tie to the taskbar
    set App(menu) [menu [string trimright $App(mw) .].popup -tearoff 0]
    $App(menu) add command -label "Settings" -underline 0 \
        -command [list [namespace origin Settings] $Application]
    $App(menu) add command -label "Test" -underline 0 \
        -command [list [namespace origin Notify] $Application]
    $App(menu) add command -label "Console" -command {console show}
    $App(menu) add command -label "Exit"     -underline 1 \
        -command [list [namespace origin Exit] $Application]

    # Hook up our taskbar icon and callback procedure
    winico text $App(icon) $App(text)
    winico taskbar add $App(icon) -pos 0 \
        -callback [list [namespace origin Callback] $Application %m %i %x %y]

    winico setwindow $App(mw) $App(icon) small 0
    wm protocol $App(mw) WM_DELETE_WINDOW \
        [list [namespace origin Exit] $Application]

    # Start of our timer so we can display a countdown 
    Timer $Application

    # Run the program and wait for the user to finish.
    tkwait variable [set Application](run)

    # Remove our taskbar icon and clean up.
    # This needs to be done before we destroy the window!
    winico taskbar delete $App(icon)
    winico delete $App(icon)

    # Finish.
    after cancel $App(timerid)
    after cancel $App(faderid)
    if {[winfo exists $App(mw)]} {destroy $App(mw)}
    unset $Application
}

proc TeaTimer::Callback {Application msg icon x y} {
    upvar #0 $Application App
    switch -exact -- $msg {
        WM_RBUTTONUP {
            $App(menu) post $x $y
        }
        WM_LBUTTONUP {
            $App(menu) post $x $y
        }
    }
}

proc TeaTimer::Exit {Application} {
    set [set Application](run) 1
}

proc TeaTimer::Timer {Application} {
    upvar #0 $Application App
    set now [clock seconds]

    if {$App(alarm) == 0} {
        set App(alarm) [expr {$now + $App(interval)}]
    }

    set due [expr {$App(alarm) - $now}]
    if {$due < 1} {
        Notify $Application
        set App(alarm) 0
        set App(text) "RIIIIIIINGGGGG!"
        winico taskbar modify $App(icon) -text $App(text)
    } else {
        set App(text) "Next alarm due in [DisplayTime $due]"
        winico taskbar modify $App(icon) -text $App(text)
    }

    set App(timerid) [after 1000 [list [namespace origin Timer] $Application]]
}

proc TeaTimer::Notify {Application} {
    variable uid
    upvar #0 $Application App
    set dlg [toplevel [string trimright $App(mw) .].dlg[incr uid] \
                 -class Toaster]
    wm title $dlg "Alarm"
    wm protocol $dlg WM_DELETE_WINDOW \
        [list [namespace origin Dismiss] $Application]
    wm geometry $dlg -5-35
    wm attributes $dlg -toolwindow 1 -alpha 0.99
    set txt [text $dlg.txt -background white -foreground black \
                 -width 30 -height 5 -font {Arial 12}]
    $txt insert end $App(message)
    pack $txt -side top -fill both -expand 1
    set App(toaster) $dlg
    set App(faderid) [after 500 [list [namespace origin Fade] $Application]]
}

proc TeaTimer::Fade {Application} {
    upvar #0 $Application App
    set alpha [wm attributes $App(toaster) -alpha]
    if {$alpha < 0.50} {
        Dismiss $Application
    } else {
        wm attributes $App(toaster) -alpha [expr {$alpha - 0.02}]
        set App(faderid) [after 500 \
                              [list [namespace origin Fade] $Application]]
    }
}

proc TeaTimer::Dismiss {Application} {
    upvar #0 $Application App
    after cancel $App(faderid)
    destroy $App(toaster)
    unset App(toaster)
}

proc TeaTimer::Settings {Application} {
    upvar #0 $Application App
    set dlg [toplevel [string trimright $App(mw) .].settings]
    wm title $dlg "Tea timer settings"
    wm geometry $dlg -5-35

    set App(intervaltxt) [DisplayTime $App(interval)]

    label $dlg.l0 -text "Message"
    entry $dlg.msg -textvariable [set Application](message)
    label $dlg.l1 -text "Interval (h:m:s)"
    entry $dlg.cnt -textvariable [set Application](intervaltxt)
    button $dlg.close -text Close -command [list set [set Application](dlg) 1]

    grid $dlg.l0 $dlg.msg -sticky nw
    grid $dlg.l1 $dlg.cnt -sticky nw
    grid $dlg.close - -sticky se
    tkwait variable [set Application](dlg)

    scan $App(intervaltxt) %02d:%02d:%02d h m s
    set new [expr {($h * 3600) + ($m * 60) + $s}]
    if {$new != $App(interval)} {
        set App(interval) $new
        set App(alarm) 0; # causes the timer to schedule the new interval.
    }

    destroy $dlg
}

proc TeaTimer::DisplayTime {seconds} {
    set hrs [expr {$seconds / 3600}]
    set min [expr {($seconds - ($hrs * 60)) / 60}]
    set sec [expr {$seconds % 60}]
    return [format "%02d:%02d:%02d" $hrs $min $sec]
}

# -------------------------------------------------------------------------

if {!$tcl_interactive} {
    set r [catch [linsert $argv 0 TeaTimer::Main .] err]
    if {$r} {puts $::errorInfo} else {puts $err}
    exit $r
}

# -------------------------------------------------------------------------
# Local variables:
# mode: tcl
# indent-tabs-mode: nil
# End:
