#
# genpasswd.tcl -- Generate Random Passwords
#
# Copyright (C) 2021-2026 by Alexander Schoepe, Bochum, DE
# All rights reserved.
#
# See the file "license.terms" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# Randomness comes from web::randombytes (CSPRNG). Indices are drawn
# with rejection sampling (no modulo bias); the final shuffle is
# Fisher-Yates, so every permutation is equally likely.
#

oo::class create web::genPasswd {
  constructor { {len 10} } {
    my variable data
    my variable rules

    # ambiguous characters (l, I, O, 0) are excluded on purpose
    set data(lower) "abcdefghijkmnopqrstuvwxyz"
    set data(upper) "ABCDEFGHJKLMNPQRSTUVWXYZ"
    set data(numbers) "123456789"
    set data(punctuation) "_+-./!*?%&$"

    if {![string is integer -strict $len] || $len < 4} {
      set len 10
    }
    set rules(len) $len
    set rules(lower,min) 1
    set rules(upper,min) 1
    set rules(numbers,min) 1
    set rules(punctuation,min) 1
  }

  # Uniform random integer in [0, n), n <= 256; rejection sampling to
  # avoid modulo bias.
  method RandomInt { n } {
    set limit [expr {256 - (256 % $n)}]
    while {1} {
      binary scan [web::randombytes 1] cu byte
      if {$byte < $limit} {
        return [expr {$byte % $n}]
      }
    }
  }

  method OneCharFrom { str } {
    return [string index $str [my RandomInt [string length $str]]]
  }

  # Fisher-Yates shuffle
  method Shuffle { str } {
    set chars [split $str {}]
    for {set i [expr {[llength $chars] - 1}]} {$i > 0} {incr i -1} {
      set j [my RandomInt [expr {$i + 1}]]
      if {$i != $j} {
        set tmp [lindex $chars $i]
        lset chars $i [lindex $chars $j]
        lset chars $j $tmp
      }
    }
    return [join $chars {}]
  }

  # configure ?key? ?value? -- get all, get one, or set one rule.
  # Keys: len, lower,min upper,min numbers,min punctuation,min
  method configure { args } {
    my variable rules

    switch -- [llength $args] {
      0 {
        return [array get rules]
      }
      1 {
        set key [lindex $args 0]
        if {![info exists rules($key)]} {
          error "unknown rule \"$key\": must be [join [lsort [array names rules]] {, }]"
        }
        return $rules($key)
      }
      2 {
        lassign $args key value
        if {![info exists rules($key)]} {
          error "unknown rule \"$key\": must be [join [lsort [array names rules]] {, }]"
        }
        if {![string is integer -strict $value] || $value < 0} {
          error "rule \"$key\": expected non-negative integer, got \"$value\""
        }
        set rules($key) $value
        return $value
      }
      default {
        error "wrong # args: should be \"configure ?key? ?value?\""
      }
    }
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

    set len [expr {$rules(len) - [string length $password]}]
    for {set i 1} {$i <= $len} {incr i} {
      append password [my OneCharFrom $all_data]
    }

    return [my Shuffle $password]
  }
}

package provide genpasswd 1.1
