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
    set payload [base64url_decode $payload64url]
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

    # Opt-in time-claim validation (RFC 7519). Default is signature-only:
    # without -claims, exp/nbf are NOT evaluated and behaviour is unchanged.
    # With -claims, a signature-valid token is additionally rejected when
    # not-yet-active (nbf - leeway > now) or expired (exp + leeway <= now).
    # Optional clock-skew tolerance: -leeway <seconds> (default 0; only
    # effective together with -claims; a non-integer/negative value is
    # treated as 0). Precedence: signature -> notbefore -> expired.
    # 'reason' is one of: ok signature notbefore expired payload.
    set reason [expr {$verify ? {ok} : {signature}}]
    if {$verify && {-claims} in $args} {
      set now [clock seconds]
      set leeway 0
      set li [lsearch -exact $args -leeway]
      if {$li >= 0} {
        set leeway [lindex $args [expr {$li + 1}]]
        if {![string is integer -strict $leeway] || $leeway < 0} {
          set leeway 0
        }
      }
      if {[catch {
        if {[json exists $payload nbf] && [json get $payload nbf] - $leeway > $now} {
          set verify false
          set reason notbefore
        } elseif {[json exists $payload exp] && [json get $payload exp] + $leeway <= $now} {
          set verify false
          set reason expired
        }
      }]} {
        set verify false
        set reason payload
      }
    }

    if {{-json} in $args} {
      # Result document. header/payload are stored as JSON *string* values
      # holding the raw JSON text (not embedded objects), so every field of
      # the result yields directly usable text/boolean:
      #   json get $res verify   -> 1 / 0           (boolean)
      #   json get $res header   -> {"alg":"HS256",...}   (re-parsable text)
      #   json get $res payload  -> {"sub":"alice",...}   (re-parsable text)
      # Read a claim in two steps:
      #   set claims [json get $res payload]
      #   json get $claims exp
      # With -claims, an extra 'reason' field is added (see above).
      json set jo verify $verify
      json set jo header [json string $header]
      json set jo payload [json string $payload]
      if {{-claims} in $args} {
        json set jo reason $reason
      }
      return $jo
    } else {
      return $verify
    }
  }
}

package provide jwt 1.0
