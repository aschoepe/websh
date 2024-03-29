#
# filerandom.tcl -- UUID generator for web::filecontext
#
# Copyright (C) 2021-2024 by Alexander Schoepe, Bochum, DE
# All rights reserved.
#
# See the file "license.terms" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

oo::class create web::filerandom {
  constructor { pathname } {
    my variable path
    my variable fname
    my variable random

    set fname lastUUID
    set path $pathname
  }

  destructor {
  }

  method UuidV4 {} {
    set r [web::randombytes 16]
    binary scan [string index $r 6] cu b6
    set b6 [binary format c [expr {($b6 & 0x0F) | 0x40}]]
    binary scan [string index $r 8] cu b8
    set b8 [binary format c [expr {($b8 & 0x3F) | 0x80}]]
    set u [binary encode hex [string range $r 0 5]${b6}[string index $r 7]${b8}[string range $r 9 end]]
    return [string range $u 0 7]-[string range $u 8 11]-[string range $u 12 15]-[string range $u 16 19]-[string range $u 20 end]
  }

  method config {} {
    # Returns a flat list of key value pairs with the filerandom's configuration.
    my variable path

    return [list pathname $path]
  }

  method nextval {} {
    # Returns the new value.
    my variable path
    my variable fname
    my variable random

    file mkdir $path

    set random [my UuidV4]
    while {[file exists [file join $path $random]]} {
      set random [my UuidV4]
    }

    if {[catch {open [file join $path $fname] w} fd]} {
      error "[self object]: $fd"
    } else {
      puts $fd $random
      close $fd
    }
    web::log info "[self object] nextval $random"
    return $random
  }

  method curval {} {
    # Returns the current value, that is, the value that the last call to "nextval" or "getval" reported (as opposed to the current value in the file).
    my variable random

    if {![info exists random]} {
      error "[self object]: no current value available"
    }
    web::log info "[self object] curval $random"
    return $random
  }

  method getval {} {
    # Returns the current value in the file. (Does not renew file as in "nextval".)
    my variable path
    my variable fname
    my variable random
    
    if {[catch {open [file join $path $fname] r} fd]} {
      error "[self object]: $fd"
    } else {
      if {![eof $fd]} {
        gets $fd random
      }
      close $fd
    }
    web::log info "[self object] getval $random"
    return $random
  }
}
