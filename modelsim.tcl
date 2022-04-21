alias r3 "reggie -b; restart -f; run -a"
alias r2 "restart -f; run -a"
alias r1 "run -a"
alias r2c {set to [getactivecursortime]; restart -f; run $to}
alias r3c {set to [getactivecursortime]; reggie -b; restart -f; run $to}
alias rs "restart -f"
alias ts "tail simulation.log"
alias cs "cat simulation.log"
alias vnw "view -new wave"
alias rh "radix h"
alias rd "radix d"
alias rb "radix b"
alias ru "radix u"
alias daw "do allwaves.do"
alias ala "add log -r *"

# run -c for n times
proc rc {n} {
  for {set x 0} { $x<$n } {incr x} { run -c }
}

# save waves
# save all open wave windows
proc sw {} {
  echo "Creating allwaves.do"
  set fp [open "allwaves.do" "w"]

  # allwaves.do will close existing Wave windows first
  puts $fp {foreach n [lsearch -all -inline [view] "*.wave*"] { noview $n }}

  foreach w [view] {
    if {[string match "*.wave*" $w]} {

      regsub .main_pane. $w "" wname

      echo "Processing $wname"
      write format wave -window  $w.interior.cs.body.pw.wf $wname.do
      regsub wave $wname "Wave" title
      puts $fp "view wave -new -title $title"
      puts $fp "do $wname.do"
    }
  }
  echo "Done"
  close $fp
}

# close all waves
# Modelsim remembers all the wave windows you have open last time you ran it,
# and reopens them.  This can be annoying, correction : it IS annoying
proc cw {} {
  foreach n [lsearch -all -inline [view] "*.wave*"] { noview $n }
}
