#
# webutils.tcl -- Some Utility Procs
#
# Copyright (C) 2021-2024 by Alexander Schoepe, Bochum, DE
# All rights reserved.
#
# See the file "license.terms" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#


# loglevel: alert error warning info debug

if {{getrandom} in [web::randombytes names]} {
  web::randombytes source getrandom
}

proc web::ts { {ms {}} } {
  if {$ms eq {}} {
     set ms [clock milliseconds]
  }
  return [clock format [expr {$ms / 1000}] -format {%Y-%m-%dT%H:%M:%S}].[format %03d [expr {$ms % 1000}]]
}


proc web::setupConfig { {context config} } {
  variable configContext
  set configContext $context
}


proc web::setupSession { {context session} } {
  variable configContext
  variable sessionContext
  set sessionContext $context

  # create an id generator (uuid v4)
  web::filerandom create idgen [${configContext}::cget path]
  # setup session context handler with the predefined id generator
  web::filecontext $sessionContext -path [file join [config::cget path] %s] -idgen "idgen nextval" -crypt off
}


proc web::initSession { id } {
  variable configContext
  variable sessionContext

  if {[catch {${sessionContext}::init $id}]} {
    return false
  }
  ${configContext}::cset sid [string range [session::id] end-7 end]
  web::logdest delete [lindex [web::logdest names] 0]
  web::logdest add -format "\[\$p\] [${configContext}::cget sid {        }] t-api/[${configContext}::cget project]: \$m\n" *.-debug syslog 10
  return true
}


proc web::uuidV4 {} {
  set r [web::randombytes 16]
  binary scan [string index $r 6] cu b6
  set b6 [binary format c [expr {($b6 & 0x0F) | 0x40}]]
  binary scan [string index $r 8] cu b8
  set b8 [binary format c [expr {($b8 & 0x3F) | 0x80}]]
  set u [binary encode hex [string range $r 0 5]${b6}[string index $r 7]${b8}[string range $r 9 end]]
  return [string range $u 0 7]-[string range $u 8 11]-[string range $u 12 15]-[string range $u 16 19]-[string range $u 20 end]
}


proc web::getContent {} {
  return [encoding convertfrom utf-8 [web::request CONTENT_DATA]]
}


proc web::returnJson { json } {
  fconfigure [web::response] -encoding utf-8
  web::response -set Content-Type {application/json}
  web::response -set Content-Length [string length [encoding convertto utf-8 $json]]
  web::response -set Cache-Control {no-cache, no-store, must-revalidate}
  web::response -set Pragma no-cache
  web::response -set Expires 0
  web::put $json
  web::response -reset
}


proc web::returnBinary { mimetype data filename } {
  switch -- $mimetype {
    pdf {
      set mimetype application/pdf
    }
  }
  fconfigure [web::response] -translation binary
  web::response -set Content-Type $mimetype
  web::response -set Content-Length [string length $data]
  web::response -set Content-Disposition "attachment; filename=[file tail $filename]"
  web::response -set Cache-Control {no-cache, no-store, must-revalidate}
  web::response -set Pragma no-cache
  web::response -set Expires 0
  web::put $data
}
