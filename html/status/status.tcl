proc status { {pipeline ""} {args ""} } {
    # This is the set of known pipelines
    # This is where you want to add a new pipeline to status.
    set knownPipes "spool oddEven ssc trimFangs astrom psp frames stuff nfcalib setQuality tarTape"
    append knownPipes " bias enstore framesLog biasPrep1 plate export"
    append knownPipes " spectroFile sp1dFarms sp1dFile 2d 1d 2d1d 2d1dFile"
    append knownPipes " 2d1dInspect inspection"

    if {$pipeline == ""} {
	echo I know how to do status for the following pipelines:
	foreach p [lsort $knownPipes] {
	    echo "\t$p"
	}
	return 1
    }
    if {[lsearch $knownPipes $pipeline] == -1} {
	echo I do not know how to do status for $pipeline
	return 1
    }
    return [eval status_$pipeline $args]
}

proc statusBiasPrep1 {run rerun columns verbose} {
    global rootDir
    set pfn $rootDir/standards/calib/$run/biPlan.par
    if {![file exists $pfn]} {
	echo The file $pfn does not exist
	return 1
    }
    param2Chain $pfn biHead
    foreach p "startField endField inputDir" {
	set $p [keylget biHead $p]
	echo $p=[set $p]
    }
    set retval 0
    if {$columns == "ALL"} {
	set columns "1 2 3 4 5 6"
    }
    foreach col $columns {
	set nfound 0
	set nnotfound 0
	loop i $startField [expr $endField+1] {
	    foreach f "u g r i z" {
		set fn [format "$inputDir/$col/idR-%06d-$f$col-%04d.fit" $run $i]
		if {[file exists $fn]} {
		    incr nfound
		} else {
		    incr nnotfound
		    set retval 1
		    echo $fn not found
		}
	    }
	}
	echo run=$run col=$col nfound=$nfound nnotfound=$nnotfound
    }
    return $retval
}

# Check for expected files in a directory
#  dir is the directory, we cd to it and cd back
#  prefix is the prefix part of the file name
proc checkOutStatus {dir prefix run rerun col startField endField verbose} {
  set Nmnf 0
  set here [pwd]
  cd $dir
  
  set fstring "%s-%06d-%s-%04d.fit"

  foreach pre $prefix {
    set nmnf 0
    set sf $startField
    set gPre [format "%s-%06d-%s-*" $pre $run $col]

    if {[catch "glob $gPre" flist]} {
        echo No files like $gPre
        set flist {}
    }
    foreach fil [lsort $flist]  {
      set fl [string trimright $fil .R]
      set fl [string trimright $fil .gz]

      if { $sf > $endField } {
        if { $verbose > 1} { echo $fl is an Unexpected file }
      } else {
        if { [format $fstring $pre $run $col $sf] == $fl} {
          incr sf
        } elseif { [format $fstring $pre $run $col $sf] > $fl   } {
          if { $verbose > 1 } { echo $fl is an Unxepected file }
        } else {
          while { [format $fstring $pre $run $col $sf] < $fl  } {
            if { $verbose > 1 } {
              echo [format $fstring $pre $run $col $sf] missing
            }
            incr nmnf
            incr sf
          }
          incr sf
        }
      }
    }
    while { $sf <= $endField } {
      if { $verbose > 1 } {
        echo [format $fstring $pre $run $col $sf] missing.
      }
      incr sf
      incr nmnf
    }
    if {$verbose > -1} {
      echo [format "run=%4d  rerun=%d col=%s %12s nFound=%5d nNotFound=%5d" \
         $run $rerun $col $pre [expr $endField-$startField+1-$nmnf] $nmnf]
    }
    incr Nmnf $nmnf
  }
  cd $here
  return $Nmnf
}

# Check for expected files with a file for each filter
proc checkOutStatusFilt {dir prefix run rerun col startField endField verbose} {
  set Nmnf 0
  set here [pwd]
  cd $dir
  set fstring "%s-%06d-%s%d-%04d.fit"
  set gstring "%s-%06d-%s%d-%04d.fit.gz"

  foreach pre $prefix {
    set nmnf 0
    foreach filt {g i r u z } {
      set sf $startField
      if {[catch "glob $pre*-$filt$col-*" flist]} {
        echo No files like $pre*-$filt$col-*
        set flist {}
      }
      foreach fil [lsort $flist] {
        set fl [string trimright $fil .R]
        if { $sf > $endField } {
          if { $verbose > 1} { echo $fl is an Unexpected file }
        } else {
          if { [format $fstring $pre $run $filt $col $sf] == $fl ||  [format $gstring $pre $run $filt $col $sf] == $fl } {
            incr sf
          } elseif { [format $fstring $pre $run $filt $col $sf] > $fl || [format $gstring $pre $run $filt $col $sf] == $fl
          } {
            if { $verbose > 1 } { echo $fl is an Unxepected file }
          } else {
            while { [format $fstring $pre $run $filt $col $sf] < $fl || [format $fstring $pre $run $filt $col $sf] < $fl } {
              if { $verbose > 1 } {
                echo [format $fstring $pre $run $filt $col $sf] missing
              }
              incr nmnf
              incr sf
            }
            incr sf
          }
        }
      }
      while { $sf <= $endField } {
        if { $verbose > 1 } {
          echo [format $fstring $pre $run $filt $col $sf] missing
        }
        incr nmnf
        incr sf
      }
    }
    if {$verbose > -1} {
     echo [format "run=%4d  rerun=%d col=%d %12s nFound=%5d nNotFound=%5d" \
         $run $rerun $col $pre [expr 5*($endField-$startField+1)-$nmnf] $nmnf]
    }
    incr Nmnf $nmnf
  }
  cd $here
  return $Nmnf
}

proc checkOutStatusRerun {dir prefix run col rerun startField endField verbose} {
  set Nmnf 0
  set here [pwd]
  cd $dir
  set fstring "%s-%06d-%d-%d-%04d.fit"
  foreach pre $prefix {
    set nmnf 0
    set sf $startField
    set gPre [format "%s-%06d-%d-%d-*.fit" $pre $run $col $rerun]
    if {[catch "glob $gPre" flist]} {
        echo No files like $gPre
        set flist {}
    }
    foreach fil [lsort $flist]  {
      set fl [string trimright $fil .R]
      if { $sf > $endField } {
        if { $verbose > 1} { echo $fl is an Unexpected file }
      } else {
        if { [format $fstring $pre $run $col $rerun $sf] == $fl } {
          incr sf
        } elseif { [format $fstring $pre $run $col $rerun $sf] > $fl } {
          if { $verbose > 1 } { echo $fl is an Unxepected file }
        } else {
          while { [format $fstring $pre $run $col $rerun $sf] < $fl && $sf <= $endField} {
            if { $verbose > 1 } {
              echo [format $fstring $pre $run $col $rerun $sf] missing
            }
            incr nmnf
            incr sf
          }
          incr sf
        }
      }
    }
    while { $sf <= $endField } {
      if { $verbose > 1 } {
        echo [format $fstring $pre $run $col $rerun $sf] missing.
      }
      incr sf
      incr nmnf
    }
    if {$verbose > 0} {
      echo [format "run=%4d  rerun=%d col=%s %12s nFound=%5d nNotFound=%5d" \
         $run $rerun $col $pre [expr $endField-$startField+1-$nmnf] $nmnf]
    }
    incr Nmnf $nmnf
  }
  cd $here
  return $Nmnf
}

proc checkOutStatusSpectro {dir prefix suffix mjd plate startField endField verbose} {
    set Nmnf 0
    set here [pwd]
    cd $dir
    set fstring "%s-%d-%04d-%03d.%s"
    set nmnf 0
    set sf $startField
    set gPre [format "%s-%d-%04d-*.%s" $prefix $mjd $plate $suffix]
    if {[catch "glob $gPre" flist]} {
	if {$verbose > 1} {echo No files like $gPre}
	set flist {}
    }
    foreach fil [lsort $flist]  {
	if { $sf > $endField } {
	    if { $verbose > 1} { echo $fil is an Unexpected file }
	} else {
	    if { [format $fstring $prefix $mjd $plate $sf $suffix] == $fil } {
		incr sf
	    } elseif { [format $fstring $prefix $mjd $plate $sf $suffix] > $fil } {
		if { $verbose > 1 } { echo $fil is an Unxepected file }
	    } else {
		while { [format $fstring $prefix $mjd $plate $sf $suffix] < $fil && $sf <= $endField} {
		    if { $verbose > 1 } {
			echo [format $fstring $prefix $mjd $plate $sf $suffix] missing
		    }
		    incr nmnf
		    incr sf
		}
		incr sf
	    }
	}
    }
    while { $sf <= $endField } {
	if { $verbose > 1 } {
	    echo [format $fstring $prefix $mjd $plate $sf $suffix] missing.
	}
	incr sf
	incr nmnf
    }
    if {$verbose > 0} {
	echo [format "plate=%4d  mjd=%d  %12s nFound=%5d nNotFound=%5d" \
		$plate $mjd $prefix [expr $endField-$startField+1-$nmnf] $nmnf]
    }
    incr Nmnf $nmnf
    cd $here
    return $Nmnf
}
