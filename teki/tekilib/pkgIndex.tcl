# Tcl package index file, version 1.0
# This file is generated by the "pkg_mkIndex" command
# and sourced either when an application starts up or
# by a "package unknown" script.  It invokes the
# "package ifneeded" command to set up package-related
# information so that packages will be loaded automatically
# in response to "package require" commands.  When this
# script is sourced, the variable $dir must contain the
# full path name of this file's directory.

package ifneeded Debug 1.0 [list tclPkgSetup $dir Debug 1.0 {{debug.tcl source {Debug_Enter Debug_FatalError Debug_Leave Debug_Print}}}]
package ifneeded Progress-Tcl 1.0 [list tclPkgSetup $dir Progress-Tcl 1.0 {{progress-tcl.tcl source {Progress_StepEnd Progress_StepInit Progress_StepPrint}}}]
package ifneeded Progress-Tk 1.0 [list tclPkgSetup $dir Progress-Tk 1.0 {{progress-tk.tcl source {ProgressCenterWindow Progress_StepEnd Progress_StepInit Progress_StepPrint}}}]
package ifneeded Undo 1.0 [list tclPkgSetup $dir Undo 1.0 {{undo.tcl source {Undo_Add Undo_All Undo_Clear}}}]
package ifneeded Wise 1.0 [list tclPkgSetup $dir Wise 1.0 {{wise.tcl source {WiseCreateLogo WiseMakeWizard Wise_CenterWindow Wise_Checklist Wise_GetDirName Wise_Message Wise_Radiolist}}}]
# package ifneeded http 1.0 [list tclPkgSetup $dir http 1.0 {{http.tcl source {httpCopyDone httpCopyStart httpEof httpEvent httpFinish httpMapReply httpProxyRequired http_code http_config http_data http_formatQuery http_get http_reset http_size http_status http_wait}}}]
