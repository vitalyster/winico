#set FNAME	"test2.tcl"


proc GetString {strbuf stindex} {
	set t [string index $strbuf $stindex]
	set b1 "{"
	set b2 "}"
	set flag2 0

	if {$t == $b1} {
		set flag 0
		set tbuf ""
	} else {
		set flag -1

		if {$t != "\""} {
			set tbuf "\""
			set flag2 1
		}
	}

	while {1} {
		if {$t == $b1} {
			set flag [expr $flag+1]
		}

		if {$t == $b2} {
			set flag [expr $flag-1]
		}
		
		set tbuf "$tbuf$t"
		set stindex [expr $stindex+1]
		set t [string index $strbuf $stindex]

		if {$flag == 0} {
			break
		} elseif {$flag == -1 && $t == "\n"} {
			break
		} elseif {$flag == -1 && $t == ""} break

# Return error if closing brace not found and end of string reached
		if {$t == ""} {
			return -1
		}

	}

	if {$flag2 == 1} {
		set tbuf "$tbuf\""
	}

	return $tbuf
}

#---------------------------------------------------------------------------
# Function:	TekiLoadTekFile
#			Read .tek file and load the various parameters
# Parameters:	tek_fname	- ".tek" file name
# Returns:		1 On Success
#				-1 If unable to open file
#---------------------------------------------------------------------------

proc TekiLoadTekFile {tek_fname} {
set patterns {{"System *Names *= *" "set tekiInfo(systemNames)"}
			  {"Package *Id. *= *" "lappend newPackage(available)"}
			  {"Package *Name *= *" "set newPackage(\$pkgid,name)"}
			  {"Version *= *" "set newPackage(\$pkgid,version)"}
			  {"Description *= *" "set newPackage(\$pkgid,description)"}
			  {"Requires *= *" "set newPackage(\$pkgid,requires)"}
			  {"Teki *File *= *" "set newPackage(\$pkgid,tekiFile)"}
			  {"Update *URL *= *" "set newPackage(\$pkgid,updateURL)"}
			  {"Register *URL *= *" "set newPackage(\$pkgid,registerURL)"}
			  {"Source *URL *= *" "set newPackage(\$pkgid,srcURL)"}
			  {"Source *Directory *= *" "set newPackage(\$pkgid,srcDir)"}
			  {"Destination *Directory *= *" "set newPackage(\$pkgid,destDir)"}
			  {"Copyright *= *" "set newPackage(\$pkgid,copyright)"}
			  {"Information *File *= *" "set newPackage(\$pkgid,infoFile)"}
			  {"Tcl *Files *= *" "set newPackage(\$pkgid,tclFiles)"}
			  {"Data *Files *= *" "set newPackage(\$pkgid,dataFiles)"}
			  {"Document *Directory *= *" "set newPackage(\$pkgid,docDir)"}
			  {"Document *Files *= *" "set newPackage(\$pkgid,docFiles)"}
			  {"Example *Files *= *" "set newPackage(\$pkgid,exampleFiles)"}
			  {"Object *Files *= *" "set newPackage(\$pkgid,objFiles)"}
			  {"Default *Packages *= *" "set newPackage(defaultPackages)"}
			  {"Default *Architecture *= *" "set newPackage(defaultArch)"}
			  {"Default *Install *Documentation *= *" "set newPackage(defaultInstallDoc)"}
			  {"Default *Install *Examples *= *" "set newPackage(defaultInstallExamples)"}
			  {"Default *Install *Data *= *" "set newPackage(defaultInstallData)"}}

    if {[string length $tek_fname] &&
       [file exists $tek_fname] &&
       [file readable $tek_fname]} {
		file stat $tek_fname flstat
        set f [open $tek_fname r]
		set fl_buf ""

		while {[gets $f line] >= 0} {
# Remove all square brackets so that a malicious user may not enter an executable command
			regsub -all \[|\] $line \# line
			regsub -all -nocase {\#+[^#]*} $line "" line

			if {[string length $line] != 0} {
				set fl_buf "$fl_buf\n$line"
			}
		}

        close $f
    } else {
        return -1
    }        

#	puts $fl_buf
	set tf [open tmp.tcl w]
	set j 0
		 
	foreach i $patterns {
		regexp -indices [lindex $i 0] $fl_buf x
		set tstr [GetString $fl_buf [expr [lindex $x 1]+1]]

		if {$j == 1} {
			set pkgid $tstr
		}

		if {$j == 17 || $j == 18} {
			set tclscript "[lindex $i 1] \[glob $tstr\]"
		} else {
			set tclscript "[lindex $i 1] $tstr"
		}

		puts $tf $tclscript\n
		set j [expr $j+1]
	}

	close $tf

}
