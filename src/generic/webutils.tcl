#
# webutils.tcl -- Some Utility Procs
#
# Copyright (C) 2021-2025 by Alexander Schoepe, Bochum, DE
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
  if {![string is wideinteger -strict $ms]} {
     set ms [clock milliseconds]
  }
  return [clock format [expr {$ms / 1000}] -format {%Y-%m-%dT%H:%M:%S}].[format %03d [expr {$ms % 1000}]]
}

proc web::configSetup { {context ::config} } {
  variable configContext

  set configContext $context
  web::context $configContext
}

proc web::sessionSetup { {context ::session} } {
  variable configContext
  variable sessionContext

  set sessionContext $context

  # create an id generator (uuid v4)
  set idgen [web::filerandom create new [${configContext}::cget path]]
  # setup session context handler with the predefined id generator
  web::filecontext $sessionContext -path [file join [config::cget path] %s] -idgen "$idgen nextval" -crypt off
}

proc web::loggingSetup { level {syslog 10} } {
  variable configContext

  web::loglevel add $level
  web::logdest add -format "\[\$p\] [${configContext}::cget sessionTag {--------}] [${configContext}::cget apiTag api]/[${configContext}::cget project]: \$m\n" *.-debug syslog 10
}

proc web::sessionGet {} {
  variable sessionContext

  set rs [dict create]
  foreach key {iss sub aud exp nbf iat jti mlt} {
    dict set rs $key [${sessionContext}::cget session($key) {}]
  }
  return $rs
}

proc web::sessionNew { {timeout 3600000} {subject subject} {audience audience} {maxlifetime 0} } {
  variable sessionContext

  if {![catch {${sessionContext}::new} rc]} {
    # iss Issuer
    # sub Subject
    # aud Audience
    # exp Expiration Time
    # nbf Not Before
    # iat Issued At
    # jti JWT ID
    # mlt Max Life Time

    set ms [clock milliseconds]
    if {![string is integer -strict $timeout]} {
      set timeout 3600000
    }
    if {![string is integer -strict $maxlifetime]} {
      set maxlifetime 0
    }

    ${sessionContext}::cset session(iss) [set iss [web::request SERVER_NAME]]
    ${sessionContext}::cset session(sub) [set sub $subject]
    ${sessionContext}::cset session(aud) [set aud $audience]
    ${sessionContext}::cset session(exp) [set exp [expr {$ms + $timeout}]]
    ${sessionContext}::cset session(nbf) [set nbf $ms]
    ${sessionContext}::cset session(iat) [set iat $ms]
    ${sessionContext}::cset session(jti) [set jti [${sessionContext}::id]]
    ${sessionContext}::cset session(mlt) [set mlt [expr {$ms + $maxlifetime}]]

    web::response -set X-Session [subst -nobackslashes -nocommands {{"iss":"$iss","sub":"$sub","aud":"$aud","exp":$exp,"nbf":$nbf,"iat":$iat,"jti":"$jti","mlt":$mlt}}]

    ${sessionContext}::clappend pids [pid]
    ${sessionContext}::cset initialReq(pid) [pid]
    ${sessionContext}::cset initialReq(ms) $ms
    foreach item {REMOTE_ADDR SERVER_ADDR HTTP_USER_AGENT} {
      ${sessionContext}::cset initialReq($item) [web::request $item]
    }

    ${sessionContext}::commit
    web::log info "sessionNew [${sessionContext}::id]"

    return [${sessionContext}::id]
  } else {
    web::log info "sessionNew: $rc"
  }
  return {}
}

# uuid for testing only, not needed in real life
proc web::sessionInit { {uuid {}} } {
  variable configContext
  variable sessionContext

  set id [web::request AUTH_BEARER $uuid]

  if {$id eq {}} {
    web::log info "Authorization Bearer not found"
    return false
  }
  if {[catch {${sessionContext}::init $id} rc]} {
    web::log info "session init failed: $rc"
    return false
  }
  if {[${sessionContext}::cget sessionClosed false]} {
    web::log info "session $id has closed flag set"
    web::response -set X-Status sessionClosed
    return false
  } 

  set sessionActive true
  set ms [clock milliseconds]
  web::log info "ms $ms"
  foreach tag {exp mlt} {
    set tm [${sessionContext}::cget session($tag) 0]
  web::log info "$tag $ms > $tm [expr {$ms - $tm}]"
    if {$tm > 0 && $ms > $tm} {
      set sessionActive false
      break
    }
  }
  if {!$sessionActive} {
    web::log info "session $id expired"
    sessionClose
    return false
  }

  ${configContext}::cset sessionTag [string range [session::id] end-7 end]
  web::logdest delete [lindex [web::logdest names] 0]
  web::logdest add -format "\[\$p\] [${configContext}::cget sessionTag {        }] api/[${configContext}::cget project]: \$m\n" *.-debug syslog 10
  return true
}

proc web::sessionClose {} {
  variable sessionContext

  ${sessionContext}::cset sessionClosed true
  ${sessionContext}::commit

  web::response -set X-Status sessionClosed

  return [web::sessionGet]
}

proc web::sessionRefresh { {timeout 3600000} } {
  variable sessionContext

  set ms [clock milliseconds]
  if {![string is integer -strict $timeout]} {
    set timeout 3600000
  }

  ${sessionContext}::cset session(exp) [expr {$ms + $timeout}]
  ${sessionContext}::commit

  foreach key {iss sub aud exp nbf iat jti mlt} {
    set $key [${sessionContext}::cget session($key)]
  }
  web::response -set X-Session [subst -nobackslashes -nocommands {{"iss":"$iss","sub":"$sub","aud":"$aud","exp":$exp,"nbf":$nbf,"iat":$iat,"jti":"$jti","mlt":$mlt}}]

  return [web::sessionGet]
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
  if {[web::request CONTENT_ENCODING] in [encoding names]} {
    return [encoding convertfrom [web::request CONTENT_ENCODING] [web::request CONTENT_DATA]]
  }
  return [web::request CONTENT_DATA]
}

proc web::mimeType { token } {
  switch -nocase -- $token {
    bin { return application/octet-stream }
    bz2 { return application/x-bzip2 }
    csv { return text/csv }
    docx { return application/vnd.openxmlformats-officedocument.wordprocessingml.document }
    gz { return application/gzip }
    ics { return text/calendar }
    jpg { return image/jpeg }
    json { return application/json }
    png { return image/png }
    pdf { return application/pdf }
    rtf { return application/rtf }
    svg { return image/svg+xml }
    txt { return text/plain }
    xlsx { return application/vnd.openxmlformats-officedocument.spreadsheetml.sheet }
    xml { return application/xml }
    zip { return application/zip }
    7z { return application/x-7z-compressed }
  }
  return $token
}

proc web::returnJson { json } {
  fconfigure [web::response] -encoding utf-8
  web::response -set Content-Type [mimeType json]
  web::response -set Content-Length [string length [encoding convertto utf-8 $json]]
  web::response -set Cache-Control {no-cache, no-store, must-revalidate}
  web::response -set Pragma no-cache
  web::response -set Expires 0
  web::put $json
  web::response -reset
}

proc web::returnText { mimetype data { encoding utf-8 } } {
  if {$encoding ne {} && $encoding in [encoding names]} {
    fconfigure [web::response] -encoding $encoding
    web::response -set Content-Length [string length [encoding convertto $encoding $data]]
  } else {
    web::response -set Content-Length [string length $data]
  }
  web::response -set Content-Type [mimeType $mimetype]
  web::response -set Cache-Control {no-cache, no-store, must-revalidate}
  web::response -set Pragma no-cache
  web::response -set Expires 0
  web::put $data
  web::response -reset
}

proc web::returnBinary { mimetype data filename } {
  fconfigure [web::response] -translation binary
  web::response -set Content-Type [mimeType $mimetype]
  web::response -set Content-Length [string length $data]
  web::response -set Content-Disposition "attachment; filename=[file tail $filename]"
  web::response -set Cache-Control {no-cache, no-store, must-revalidate}
  web::response -set Pragma no-cache
  web::response -set Expires 0
  web::put $data
  web::response -reset
}