#_________________________________________________________________________________
# Project SDSS
# program name :        stat.tcl 
# Author:               Chris Stoughton, John Inkmann
# Date:                 August 3, 2001
# Purpose:              Generate graphs summarizing survey progress
# Input:                Read from skent history files
#                       and three baseline files
#__________________________________________________________________________________
proc statPlotMake { } {
    global pg stat base jpi
    statLoadBase
    statLoadImg

    # Make the gif plots
    statPlotImg gif
    statLoadSpec
    statPlotSpec gif
    statLoadPatch
    statPlotPatch gif
    statPlotSummary gif

    # Make the ps file
    pgInit /vcps
    pgstateSet $pg
    statPlotImg
    statPlotSpec
    statPlotPatch
    pgstateClose $pg
    exec mv pgplot.ps statPlot.ps
    statDiag
}
#________________________________________________________________________
proc statDiag {{fileType ""}} {

   global pg stat base
    set STATDIAG [open stat_diag.html w]
    puts $STATDIAG "<html><body bgcolor=#FFFFFF><BASEFONT SIZE=1>"
    puts $STATDIAG "IMG:"
    foreach type "NORTH SOUTH REPEAT" {
	foreach var "date unique" {
	    puts $STATDIAG "<BR>stat(l.$type.$var) $stat(l.$type.$var)"
	}
    }
    puts $STATDIAG "<HR>"
    puts $STATDIAG "SPEC:"
    foreach type "NORTH SOUTH" {
	foreach var "date tiles" {
	    puts $STATDIAG "<BR>stat(l.spec.$type.$var) $stat(l.spec.$type.$var)"
	}
    }
    puts $STATDIAG "<BR>stat(l.spec.REPEAT.date) $stat(l.spec.REPEAT.date)"
    puts $STATDIAG "<BR>stat(l.spec.REPEAT.hours) $stat(l.spec.REPEAT.hours)"
    
    puts $STATDIAG "<HR>"
    puts $STATDIAG "PATCH:"
    foreach type "NORTH SOUTH" {
	foreach var "date patches" {
	    puts $STATDIAG "<BR>stat(l.patch.$type.$var) $stat(l.patch.$type.$var)"
	}
    }
    puts $STATDIAG "</BODY></HTML>"
    close $STATDIAG    
}
#________________________________________________________________________
proc statPlotSummary {{fileType ""}} {
    global pg stat base

    set stat(PC.img) [expr  round (100 * $stat(img.grand.total) / $base(img.grand.total)) ]
    set stat(PC.spec) [expr round (100 * $stat(spec.grand.total) / $base(spec.grand.total)) ]
    set stat(PC.patch) [expr  round (100 * $stat(patch.grand.total) / $base(patch.grand.total)) ]   
    set HTMLOUT [open stat_summary.html w]
    puts $HTMLOUT "<html><body bgcolor=#FFFFFF>"
    puts $HTMLOUT "<!--Table Goes Here -->"
    puts $HTMLOUT "<table width=100% border=1 cellspacing =0 cellpadding=0>"
    puts $HTMLOUT "<tr>"
    puts $HTMLOUT "<td></td><td>Base</td> <td>Done</td>"
    puts $HTMLOUT " <td>Percent Complete</td>"
    puts $HTMLOUT "</tr>"
    puts $HTMLOUT "<!--END Table Row ----------------------------------------!>"
    puts $HTMLOUT "<tr>"
    puts $HTMLOUT "<td>"
    puts $HTMLOUT "Imaging"
    puts $HTMLOUT "</td>"
    puts $HTMLOUT "<td>"
    puts $HTMLOUT "$base(img.grand.total) (Scanned Square Degrees)"
    puts $HTMLOUT "</td> "
    puts $HTMLOUT "<td>"
    puts $HTMLOUT "$stat(img.grand.total)"
    puts $HTMLOUT "</td>"
    puts $HTMLOUT "<td>"
    puts $HTMLOUT "<IMG SRC=statSummaryimg.gif width=341 height=35><BR>"
    puts $HTMLOUT "$stat(PC.img) % as of $stat(modtime.IMG)"
    puts $HTMLOUT "</td>"
    puts $HTMLOUT "</tr>"
    puts $HTMLOUT "<!--END Table Row ---------------------------------!>"
    pgInit statSummaryimg.gif/GIF
    pgPaper 4 0.1
    pgEnv 0 100 0 1 0 2
    pgSfs 1
    pgSci 3
    pgRect 0 $stat(PC.img) 0 100
    pgClose     
    puts $HTMLOUT "<tr>"
    puts $HTMLOUT "<td>"
    puts $HTMLOUT "Spectroscopy"
    puts $HTMLOUT "</td>"
    puts $HTMLOUT "<td>"
    puts $HTMLOUT "$base(spec.grand.total) (Tiles)"
    puts $HTMLOUT "</td> "
    puts $HTMLOUT "<td>"
    puts $HTMLOUT "$stat(spec.grand.total)"
    puts $HTMLOUT "</td>"
    puts $HTMLOUT "<td>"
    puts $HTMLOUT "<IMG SRC=statSummaryspec.gif width=341 height=35><BR>"
    puts $HTMLOUT "$stat(PC.spec) % as of $stat(modtime.SPEC)"
    puts $HTMLOUT "</td>"
    puts $HTMLOUT "</tr>"
    puts $HTMLOUT "<!--END Table Row ---------------------------------!>"
    pgInit statSummaryspec.gif/GIF
    pgPaper 4 0.1
    pgEnv 0 100 0 1 0 2
    pgSfs 1
    pgSci 3
    pgRect 0 $stat(PC.spec) 0 100
    pgClose 
    puts $HTMLOUT "<tr>"
    puts $HTMLOUT "<td>"
    puts $HTMLOUT "MT (Secondary) Patches"
    puts $HTMLOUT "</td>"
    puts $HTMLOUT "<td>"
    puts $HTMLOUT "$base(patch.grand.total) (Patches)"
    puts $HTMLOUT "</td> "
    puts $HTMLOUT "<td>"
    puts $HTMLOUT "$stat(patch.grand.total)"
    puts $HTMLOUT "</td>"
    puts $HTMLOUT "<td>"
    puts $HTMLOUT "<IMG SRC=statSummarypatch.gif width=341 height=35><BR>"
    puts $HTMLOUT "$stat(PC.patch) % as of $stat(modtime.PATCH)"
    puts $HTMLOUT "</td>"
    puts $HTMLOUT "</tr>"
    puts $HTMLOUT "<!--END Table Row ---------------------------------!>"
    pgInit statSummarypatch.gif/GIF
    pgPaper 4 0.1
    pgEnv 0 100 0 1 0 2
    pgSfs 1
    pgSci 3
    pgRect 0 $stat(PC.patch) 0 100
    pgClose 
    puts $HTMLOUT "</table>"
    puts $HTMLOUT "<H1>Cumulative Progress Graphs</H1>"
    puts $HTMLOUT "<UL TYPE=CIRLE>" 
    puts $HTMLOUT "<LI><A href=statImg.NORTH.gif>North Imaging</a> "
    puts $HTMLOUT "<LI><A href=statImg.SOUTH.gif>South Imaging</A> "
    puts $HTMLOUT "<LI><A href=statImg.REPEAT.gif>Southern EQ Repeat Imaging</A>"
    puts $HTMLOUT "<LI><A href=statSpec.NORTH.gif>North Spectroscopy</a> "
    puts $HTMLOUT "<LI><A href=statSpec.SOUTH.gif>Southern Survey Spectroscopy</A>"
    puts $HTMLOUT "<LI><A href=statSpec.REPEAT.gif>Southern EQ Spectroscopy</A>"
    puts $HTMLOUT "<LI><A href=statPatch.NORTH.gif>MT Secondary Patches for North</A> "
    puts $HTMLOUT "<LI><A href=statPatch.SOUTH.gif>MT Secondary Patches for South</A>"
    puts $HTMLOUT "</UL></BODY></HTML>"
    close $HTMLOUT    
}
#________________________________________________________________________
proc statPlotPatch { {fileType ""} } {
    global pg stat base
    foreach type "NORTH SOUTH" {
	if {$fileType == "gif"} {
	    pgInit /vgif
	}
	pgstateSet $pg -xopt "CST" -isLine 1 -icLine 2 -isNewplot 1 \
		-lineStyle 2 \
		-plotTitle "$type MT Patches"
	pgIden
	pgSci 2
	pgMtext T -5 .3 1.0 "Dotted Red = BaseLine"
	pgSci 3
	pgMtext T -5 .9 1.0 "Green = Actual" 
	pgSci 1
	vNameSet $base(vp.$type.idate) ""
	vNameSet $base(vp.$type.patch) "MT Patches"
	vPlot $pg $base(vp.$type.idate) $base(vp.$type.patch)
	loop i 0 [llength $base(l.$type.quarter)] {
	    set  date [lindex $base(l.$type.quarter) $i]
	    set idate [lindex $base(l.$type.idate) $i]
	    pgPtext $idate 0 90 1.0 $date
	}
	pgstateSet $pg -isNewplot 0 -icLine 3 -lineStyle 1
	vPlot $pg $stat(vp.$type.idate) $stat(vp.$type.patches)
	if {$fileType == "gif"} {
	    pgstateClose $pg
	    exec mv pgplot.gif statPatch.$type.gif
	}
    }
}
#__________________________________________________________________________
proc statLoadPatch { } {
    global stat
    foreach type "NORTH SOUTH" {
	foreach var "date idate patches" { 
	    set stat(l.patch.$type.$var) ""
    }  
}
set stat(modtime.PATCH) [fmtclock  [file mtime  /data/dp1.0/skent/mt/patchHistory.txt]  "%b %d, %Y" ]
    for_file patchline /data/dp1.0/skent/mt/patchHistory.txt {
	set yearQuarter [lindex $patchline 0]
	if { [string index $yearQuarter 4] == "-"} {
	    if {[iFromDate [lindex $patchline 0]] <= [iFromDate [fmtclock [getclock] %Y]-[fmtclock [getclock] %b] ] } {	
		lappend stat(l.patch.NORTH.date) [lindex $patchline 0]
		lappend stat(l.patch.SOUTH.date) [lindex $patchline 0]
		lappend stat(l.patch.NORTH.idate) [iFromDate [lindex $patchline 0]]
		lappend stat(l.patch.SOUTH.idate) [iFromDate [lindex $patchline 0]]
		lappend stat(l.patch.NORTH.patches) [lindex $patchline 2]
		lappend stat(l.patch.SOUTH.patches) [lindex $patchline 3]
		set stat(l.NORTH.patchtotal) [lindex $patchline 2]
		set stat(l.SOUTH.patchtotal) [lindex $patchline 3]
	    } else {
		echo "Dismissing Line: $patchline"
	    }
	}
    }
   foreach type "NORTH SOUTH" {
	foreach var "idate patches" {
	    set stat(vp.$type.$var) \
		    [vFromL $stat(l.patch.$type.$var) $type.$var]
	}
    }
    set stat(patch.grand.total) [expr  \
    $stat(l.NORTH.patchtotal) + $stat(l.SOUTH.patchtotal)]
}
#________________________________________________________________________

proc statPlotSpec { {fileType ""} } {
    global pg stat base
    foreach type "NORTH SOUTH" {
	if {$fileType == "gif"} {
	    pgInit /vgif
	}

	set TitleString  "Northern Survey Spectroscopy"
	if {$type == "SOUTH"} { 
	    set TitleString  "Southern Survey Spectroscopy"
	}

	pgstateSet $pg -xopt "CST" -isLine 1 -icLine 2 -isNewplot 1 \
		-lineStyle 2 \
		-plotTitle "$TitleString"
	pgIden
	pgSci 2
	pgMtext T -5 .3 1.0 "Dotted Red = BaseLine"
	pgSci 3
	pgMtext T -5 .9 1.0 "Green = Actual" 
	pgSci 1
	vNameSet $base(vs.$type.idate) ""
	vNameSet $base(vs.$type.spec) "Plates"
	vPlot $pg $base(vs.$type.idate) $base(vs.$type.spec)
	loop i 0 [llength $base(l.$type.quarter)] {
	    set  date [lindex $base(l.$type.quarter) $i]
	    set idate [lindex $base(l.$type.idate) $i]
	    pgPtext $idate 0 90 1.0 $date
	}
	pgstateSet $pg -isNewplot 0 -icLine 3 -lineStyle 1
	vPlot $pg $stat(v.spec.$type.idate) $stat(v.spec.$type.tiles)
	if {$fileType == "gif"} {
	    pgstateClose $pg
	    exec mv pgplot.gif statSpec.$type.gif
	}
    }
############################################################################
# from here down, we do REPEAT spec plot (slightly different)
set type "REPEAT"
	if {$fileType == "gif"} {
	    pgInit /vgif
	}
	pgstateSet $pg -xopt "CST" -isLine 1 -icLine 2 -isNewplot 1 \
		-lineStyle 2 \
		-plotTitle "Southern EQ Spectroscopy"
	pgIden
	pgSci 2
	pgMtext T -5 .3 1.0 "Dotted Red = BaseLine"
	pgSci 3
	pgMtext T -5 .9 1.0 "Green = Actual" 
	pgSci 1
	vNameSet $base(vs.$type.idate) ""
	vNameSet $base(vs.$type.spec) "Hours"
	vPlot $pg $base(vs.$type.idate) $base(vs.$type.spec)
	loop i 0 [llength $base(l.$type.quarter)] {
	    set  date [lindex $base(l.$type.quarter) $i]
	    set idate [lindex $base(l.$type.idate) $i]
	    pgPtext $idate 0 90 1.0 $date
	}
	pgstateSet $pg -isNewplot 0 -icLine 3 -lineStyle 1
	vPlot $pg $stat(v.spec.$type.idate) $stat(v.spec.$type.hours)
	if {$fileType == "gif"} {
	    pgstateClose $pg
	    exec mv pgplot.gif statSpec.$type.gif
	}
}
#__________________________________________________________________________
proc statLoadSpec { } {
    global stat

#set inow [iFromDate [fmtclock [getclock] %Y]-[fmtclock [getclock] %b] ]

    foreach type "NORTH SOUTH REPEAT" {
	foreach var "date idate tiles" { 
	    set stat(l.spec.$type.$var) ""
    }  
}
set stat(modtime.SPEC) [fmtclock  [file mtime  /data/dp1.0/skent/mt/specHistory.txt]  "%b %d, %Y" ]
    for_file specline /data/dp1.0/skent/mt/specHistory.txt {
	set yearQuarter [lindex $specline 0]
	if { [string index $yearQuarter 4] == "-"} {
	    if {[iFromDate [lindex $specline 0]] <= [iFromDate [fmtclock [getclock] %Y]-[fmtclock [getclock] %b] ] } {
		lappend stat(l.spec.NORTH.date) [lindex $specline 0]
		lappend stat(l.spec.SOUTH.date) [lindex $specline 0]
		lappend stat(l.spec.REPEAT.date) [lindex $specline 0]
		lappend stat(l.spec.NORTH.idate) [iFromDate [lindex $specline 0]]
		lappend stat(l.spec.SOUTH.idate) [iFromDate [lindex $specline 0]]
		lappend stat(l.spec.REPEAT.idate) [iFromDate [lindex $specline 0]]
		lappend stat(l.spec.NORTH.tiles) [lindex $specline 4]
		lappend stat(l.spec.SOUTH.tiles) [lindex $specline 5]
		lappend stat(l.spec.REPEAT.tiles) [lindex $specline 6]
		set stat(l.NORTH.spectotal) [lindex $specline 4]
		set stat(l.SOUTH.spectotal) [lindex $specline 5]
		set stat(l.REPEAT.spectotal) [lindex $specline 6]
	    } else {
		echo "Dismissing Line: $specline"
	    }
	}
    }
   foreach type "NORTH SOUTH REPEAT" {
	foreach var "idate tiles" {
	    set stat(v.spec.$type.$var) \
		    [vFromL $stat(l.spec.$type.$var) $type.$var]
	}
    }
    set stat(l.spec.REPEAT.hours) ""
    foreach i $stat(l.spec.REPEAT.tiles) {
	lappend stat(l.spec.REPEAT.hours) [expr $i * 0.75]
    }


   foreach type "REPEAT" {
	foreach var "idate hours" {
	    set stat(v.spec.$type.$var) \
		    [vFromL $stat(l.spec.$type.$var) $type.$var]
	}
    }
    set stat(spec.grand.total) [expr  \
    $stat(l.NORTH.spectotal) + $stat(l.SOUTH.spectotal)]
}
#________________________________________________________________________
proc statLoadImg { } {
    global stat
set stat(modtime.IMG) [fmtclock  [file mtime  /data/dp1.0/skent/mt/imgHistory.txt]  "%b %d, %Y" ]

set inow [iFromDate [fmtclock [getclock] %Y]-[fmtclock [getclock] %b] ]

    for_file line /data/dp1.0/skent/mt/imgHistory.txt {
	if {[llength $line] > 3} {
	    if {[lindex $line 0] != "Runs:"} {
		if {[lsearch $line Gross] >= 0} {
		    set type [lindex $line 0]
		    set stat(l.$type.date) ""
		    set stat(l.$type.idate) ""
		    set stat(l.$type.unique) ""
		    set stat(l.$type.good) ""
		} else {
		    if {[iFromDate [lindex $line 0]] <= [iFromDate [fmtclock [getclock] %Y]-[fmtclock [getclock] %b] ] } {
			lappend stat(l.$type.date) [lindex $line 0]
			lappend stat(l.$type.idate) [iFromDate [lindex $line 0]]
			lappend stat(l.$type.unique) [lindex $line 4]
			lappend stat(l.$type.good) [lindex $line 3]
			set stat(l.$type.total) [lindex $line 4]
		    } else {
			echo "Dismissing Line: $line"
		    }
		}
	    }
	}
    }
###################################################################
# AUG 29, John Inkman
#per skent, create new chart, refer to it as "ORIGINAL"
#it will replace "south imaging"
#it will be the sum of south outrigger and EQ first pass
#kron identified current numbers as first pass, so future runs
#will need to be ignored (with this category) and instead counted 
#in the "repetition" chart 
##################################################################
set qtr_count [expr [llength $stat(l.SOUTH.unique)]]
#
#
#if {$qtr_count > 18} {
# set original_done 18
#} else { set original_done  $qtr_count
#} 
#
## echo temp var is $qtr_count
#set stat(l.ORIGINAL.unique) ""
#
#set stat(l.REPEAT.date) ""
#set stat(l.REPEAT.idate) ""
#set stat(l.REPEAT.unique) ""
#
#for {set i 0} { $i < $original_done} {incr i +1} { 
#    lappend stat(l.ORIGINAL.unique) \
#	    [ expr [lindex $stat(l.SOUTH.unique) $i] + [lindex $stat(l.EQ.unique) $i] ]
#    lappend stat(l.REPEAT.unique) 0 
#}
#
#for {set i $original_done} { $i < $qtr_count} {incr i +1} {
#    lappend stat(l.ORIGINAL.unique) \
#	    [ expr [lindex $stat(l.SOUTH.unique) $i] + [lindex $stat(l.EQ.unique) 16] ]
#    lappend stat(l.REPEAT.unique) \
#	    [ expr  [lindex $stat(l.EQ.unique) $i]  - [lindex $stat(l.EQ.unique) 16] ]
#}
#
#for {set i 0} { $i < $qtr_count} {incr i +1} {
#    lappend stat(l.REPEAT.date) [lindex $stat(l.SOUTH.date) $i]
#    lappend stat(l.REPEAT.idate) [lindex $stat(l.SOUTH.idate) $i]   
#}
#
## now that we are happy with ORIGINAL, rename it SOUTH for compatibility with rest of program
#set stat(l.SOUTH.unique) ""
#for {set i 0} { $i < $qtr_count} {incr i +1} {
#    lappend stat(l.SOUTH.unique) [lindex $stat(l.ORIGINAL.unique) $i]  
#}

##################################################################################
#Oct 15, 2001
#per SKent, change REPEAT IMG, EQ subcategory:  result of (GOOD minus UNIQUE)
#this is to replace code above that involved dates
#
set stat(l.SOUTH.temp) ""
set tempCount [expr [llength $stat(l.SOUTH.unique)]]
for {set i 0} {$i < $qtr_count} {incr i +1} {
    lappend stat(l.SOUTH.temp) \
	    [expr [lindex $stat(l.SOUTH.unique) $i] + [lindex $stat(l.EQ.unique) $i]]

}
set stat(l.EQ.temp) ""
set tempCount [expr [llength $stat(l.EQ.unique)]]
for {set i 0} {$i < $qtr_count} {incr i +1} {
    lappend stat(l.EQ.temp) \
	    [expr [lindex $stat(l.EQ.good) $i] - [lindex $stat(l.EQ.unique) $i]]
}
set stat(l.EQ.unique) ""
for {set i 0} {$i < $qtr_count} {incr i +1} { lappend stat(l.EQ.unique) [expr [lindex $stat(l.EQ.temp) $i]]}
set stat(l.SOUTH.unique) ""
for {set i 0} {$i < $qtr_count} {incr i +1} { 
    lappend stat(l.SOUTH.unique) [expr [lindex $stat(l.SOUTH.temp) $i]]

}

set stat(l.REPEAT.date) ""
set stat(l.REPEAT.idate) ""
set stat(l.REPEAT.unique) ""
for {set i 0} { $i < $qtr_count} {incr i +1} {
    lappend stat(l.REPEAT.date) [lindex $stat(l.EQ.date) $i]
    lappend stat(l.REPEAT.idate) [lindex $stat(l.EQ.idate) $i]   
    lappend stat(l.REPEAT.unique) [lindex $stat(l.EQ.unique) $i] 
}
#
#end of OCT 15 update
#####################################################################################
    foreach type "NORTH SOUTH REPEAT" {
	foreach var "idate unique" {
	    set stat(v.$type.$var) [vFromL $stat(l.$type.$var) $type.$var]
	}
	set stat(l.$type.total) [lindex $stat(l.$type.unique) [expr $qtr_count-1] ]
    }
  set stat(img.grand.total) [expr  \
    $stat(l.NORTH.total) + $stat(l.SOUTH.total) + $stat(l.REPEAT.total)]
##################################################################
#
#    foreach type "NORTH SOUTH EQ" {
#	foreach var "idate unique" {
#	    set stat(v.$type.$var) [vFromL $stat(l.$type.$var) $type.$var]
#	}
#    }
#
#    set stat(img.grand.total) [expr  \
#    $stat(l.NORTH.total) + $stat(l.SOUTH.total) + $stat(l.EQ.total)]
}
#_______________________________________________________________________
proc statPlotImg { {fileType ""} } {
    global pg stat base
    foreach type "NORTH SOUTH REPEAT" {
	if {$fileType == "gif"} {
	    pgInit /vgif
	}
	set titlestring  $type
	if {$type == "REPEAT"} {
	    set titlestring  "Southern EQ Repeat"}
	pgstateSet $pg -xopt "CST" -isLine 1 -icLine 2 -isNewplot 1 \
		-lineStyle 2 \
		-plotTitle "$titlestring Imaging"
	pgIden
	pgSci 2
	pgMtext T -5 .3 1.0 "Dotted Red = BaseLine"
	pgSci 3
	pgMtext T -5 .9 1.0 "Green = Actual" 
	pgSci 1
	vNameSet $base(v.$type.idate) ""
	vNameSet $base(v.$type.imaging) "Unique Square Degrees"
	vPlot $pg $base(v.$type.idate) $base(v.$type.imaging)
	loop i 0 [llength $base(l.$type.quarter)] {
	    set  date [lindex $base(l.$type.quarter) $i]
	    set idate [lindex $base(l.$type.idate) $i]
	    pgPtext $idate 0 90 1.0 $date
	}
	pgstateSet $pg -isNewplot 0 -icLine 3 -lineStyle 1
	vPlot $pg $stat(v.$type.idate) $stat(v.$type.unique)

	if {$fileType == "gif"} {
	    pgstateClose $pg
	    exec mv pgplot.gif statImg.$type.gif
	}
    }
}
#______________________________________________________________________
proc iFromDate {date} {
    set imonth(Jan)  0
    set imonth(Feb)  1
    set imonth(Mar)  2
    set imonth(Apr)  3
    set imonth(May)  4
    set imonth(Jun)  5
    set imonth(Jul)  6
    set imonth(Aug)  7
    set imonth(Sep)  8
    set imonth(Oct)  9
    set imonth(Nov) 10
    set imonth(Dec) 11
    set list [split $date -]
    set year [lindex $list 0]
    set month [lindex $list 1]
# the next line is interesting, and must be understood
# we are going to subtract 3.  SKent dates are all forward one quarter
# as in oct-2001 is cumulative up to the morning of OCT 1, 2001 

    set idate [expr 12*$year+$imonth($month)-3]
    return $idate
}
#____________________________________________________________________
proc statLoadBase { } {
    global base
    set qname(0) Jan-Mar
    set qname(3) Apr-Jun
    set qname(6) Jul-Sep
    set qname(9) Oct-Dec
    set imgGrandTotal 0
    set specGrandTotal 0
    set patchGrandTotal 0
    foreach type "NORTH SOUTH REPEAT" {
	set imgTotal 0
	set specTotal 0
	set patchTotal 0
	set base(l.$type.quarter) ""
	set base(l.$type.idate) ""
	set base(l.$type.imaging) ""
	set base(l.$type.spec) ""
	set base(l.$type.patch) ""
	for_file thisline /home/s1/inkmann/baseline/$type.JPI {
	    if {[lsearch $thisline DATA ] >= 0 } {
		set theyear [lindex $thisline 1]
		set thequarter [lindex $thisline 2]
		set theimg [lindex $thisline 15]
		set thespec [lindex $thisline 16]
		# next we calculate MT patch baseline with formula from skent
		set MTbase [ expr  $theimg /12897.5 * 1520]
		lappend base(l.$type.idate) \
			[iFromYearQuarter $theyear $thequarter]
		set imgTotal [expr $imgTotal+$theimg]
		set specTotal [expr $specTotal+$thespec]
		set patchTotal [expr $patchTotal+$MTbase]
		lappend base(l.$type.imaging) $imgTotal
		lappend base(l.$type.spec) $specTotal
		lappend base(l.$type.patch) $patchTotal
		lappend base(l.$type.quarter) "$theyear $qname($thequarter)"
	    }
	}
	set base(l.temptotal.$type) $imgTotal
	set base(l.spectemptotal.$type) $specTotal
	set imgGrandTotal [expr $imgTotal + $imgGrandTotal]
	set specGrandTotal [expr $specTotal + $specGrandTotal]
	set patchGrandTotal [expr $patchTotal + $patchGrandTotal]
    }
    set imgGrandTotal [expr $base(l.temptotal.NORTH) + $base(l.temptotal.SOUTH)]
    set specGrandTotal [expr $base(l.spectemptotal.NORTH) + $base(l.spectemptotal.SOUTH)]
    foreach type "NORTH SOUTH REPEAT" {
	foreach var "idate imaging" {
	    set base(v.$type.$var) [vFromL $base(l.$type.$var) $type.$var]
	}
	foreach var "idate spec" {
	    set base(vs.$type.$var) [vFromL $base(l.$type.$var) $type.$var]
	}
	foreach var "idate patch" {
	    set base(vp.$type.$var) [vFromL $base(l.$type.$var) $type.$var]
	}
    }

    set base(img.grand.total)     [expr round ($imgGrandTotal)]
    set base(spec.grand.total)    [expr round ($specGrandTotal)]
# echo  $base(spec.grand.total)
    set base(patch.grand.total)   [expr round ($patchGrandTotal)]
}
#_____________________________________________________________________
proc iFromYearQuarter {year quarter} {
    set i [expr 12*$year+$quarter]
    return $i
}





