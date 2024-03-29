#
# jwt.tcl -- JSON Web Tokens
#
# Copyright (C) 2022-2024 by Alexander Schoepe, Bochum, DE
# All rights reserved.
#
# See the file "license.terms" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

#
# DEPENDENCIES:
#   tcl C Package rl_json -- https://github.com/RubyLane/rl_json
#

# setup config namespace

namespace eval ::jwt {
  namespace export sign verify

  variable init
  set init false

  proc init {} {
    variable init

    if {!$init} {
      package require nacl
      package require rl_json
      namespace path ::rl_json

      set init true
    }
  }

  proc base64url_encode {string} {
    return [string map {+ - / _ = {}} [binary encode base64 $string]]
  }

  proc base64url_decode {string} {
    return [binary decode base64 [string map {- + _ /} $string]]
  }

  proc getAlg { header } {
    if {![json exists $header alg]} {
      set alg HS256
    } else {
      set alg [json get $header alg]
    }
    return $alg
  }

  proc checkSecret { secret } {
    set len [string length $secret]
    if {$len < 32} {
      set secret $secret[string repeat \0 [expr {32 - $len}]]
    } elseif {$len > 32} {
      set secret [string range $secret 0 31]
    }
    return $secret
  }

  proc sign { header payload secret } {
    init

    set header64url [base64url_encode $header]
    set payload64url [base64url_encode $payload]
    set unsignedToken [join [list $header64url $payload64url] .]

    set secret [checkSecret $secret]

    switch -- [getAlg $header] {
      HS256 {
        if {[nacl::auth -hmac256 auth $unsignedToken $secret] == 0} {
          set signature [base64url_encode $auth]
          return [join [list $unsignedToken $signature] .]
        }
      }
      HS512 {
        if {[nacl::auth -hmac512256 auth $unsignedToken $secret] == 0} {
          set signature64url [base64url_encode $auth]
          return [join [list $unsignedToken $signature64url] .]
        }
      }
      NaCl {
        if {[nacl::onetimeauth auth $unsignedToken $secret] == 0} {
          set signature64url [base64url_encode $auth]
          return [join [list $unsignedToken $signature64url] .]
        }
      }
    }
    return $unsignedToken
  }

  proc verify { token secret args } {
    init

    lassign [split $token .] header64url payload64url signature64url
    set unsignedToken [join [list $header64url $payload64url] .]

    set header [base64url_decode $header64url]
    set signature [base64url_decode $signature64url]

    set secret [checkSecret $secret]

    set verify false
    switch -- [getAlg $header] {
      HS256 {
        if {[nacl::auth verify -hmac256 $signature $unsignedToken $secret] == 0} {
          set verify true
        }
      }
      HS512 {
        if {[nacl::auth verify -hmac512256 $signature $unsignedToken $secret] == 0} {
          set verify true
        }
      }
      NaCl {
        if {[nacl::onetimeauth verify $signature $unsignedToken $secret] == 0} {
          set verify true
        }
      }
    }
    if {{-json} in $args} {
      json set jo verify $verify
      json set jo header $header
      json set jo payload [base64url_decode $payload64url]
      return $jo
    } else {
      return $verify
    }
  }
}

package provide jwt 1.0
