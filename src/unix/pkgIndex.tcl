# -*- tcl -*-
# Tcl package index file
#
# Both library flavours may coexist in one directory: TEA names the
# library libtcl9<pkg>... when built against Tcl 9 and lib<pkg>...
# when built against Tcl 8.6.
#
if {[package vsatisfies [package provide Tcl] 9.0-]} {
    package ifneeded websh 3.7.7 \
	    [list load [file join $dir libtcl9websh3.7.7[info sharedlibextension]] [string totitle websh]]
} else {
    package ifneeded websh 3.7.7 \
	    [list load [file join $dir libwebsh3.7.7[info sharedlibextension]] [string totitle websh]]
}
