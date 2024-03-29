#
# genpasswd.tcl -- Generate Random Passwords
#
# Copyright (C) 2021-2024 by Alexander Schoepe, Bochum, DE
# All rights reserved.
#
# See the file "license.terms" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

oo::class create genPasswd {
  constructor {} {
    my variable data
    my variable rules

    set data(lower) "abcdefghijkmnopqrstuvwxyz"
    set data(upper) "ABCDEFGHJKLMNPQRSTUVWXYZ"
    set data(numbers) "123456789"
    set data(punctuation) "_+-./!*?%&$"

    set rules(len) 10
    set rules(lower,min) 1
    set rules(upper,min) 1
    set rules(numbers,min) 1
    set rules(punctuation,min) 1
  }

  destructor {
  }

  method OneCharFrom { str } {
    set len [string length $str]
    set i [expr {int(rand()*$len)}]
    return [string index $str $i]
  }

  method SwapStringChars { str i j } {
    if { $i == $j } {
      return $str
    }
    if { $i > $j } {
      set t $j
      set j $i
      set i $t
    }
    set pre [string range $str 0 [expr {$i - 1}]]
    set chi [string index $str $i]
    set mid [string range $str [expr {$i + 1}] [expr {$j - 1}]]
    set chj [string index $str $j]
    set end [string range $str [expr {$j + 1}] end]
    return ${pre}${chj}${mid}${chi}${end}
  }

  method Shuffle { str } {
    set len [string length $str]
    for {set i 1} {$i <= $len} {incr i} {
      set i1 [expr {int(rand() * $len)}]
      set i2 [expr {int(rand() * $len)}]
      set str [my SwapStringChars $str $i1 $i2]
    }
    return $str
  }

  method generate {} {
    my variable data
    my variable rules

    set password {}
    foreach i [array names rules *,min] {
      set src [lindex [split $i ,] 0]
      set num $rules($i)
      for {set n 1} {$n <= $num} {incr n} {
        append password [my OneCharFrom $data($src)]
      }
    }

    set all_data {}
    foreach set [array names data] {
      append all_data $data($set)
    }

    set len [expr $rules(len) - [string length $password]]
    for {set i 1} {$i <= $len} {incr i 1} {
      append password [my OneCharFrom $all_data]
    }

    return [my Shuffle $password]
  }
}

package provide genpasswd 1.0
