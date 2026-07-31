# Websh Tcl Command Reference

Websh embeds a Tcl interpreter and adds `web::*` commands for web applications. All standard Tcl commands are available. Runs as CGI or as Apache module (`mod_websh`).

---

## Configuration — `web::config`

```tcl
web::config key ?value?
```

Returns previous value when setting a new one.

| Key | Default | Description |
|-----|---------|-------------|
| `uploadfilesize` | 0 | Max bytes saved for file upload (0 = disabled) |
| `cmdparam` | `cmd` | URL parameter name for command dispatch |
| `timeparam` | `t` | URL parameter name for timestamp |
| `cmdurltimestamp` | 1 | Include timestamp in `web::cmdurl` output |
| `logsubst` | 0 | Run `subst` on log messages |
| `safelog` | 1 | `web::log` never throws errors |
| `putxmarkup` | `brace` | Markup for `web::putx`: `brace` (`{...}`) or `tag` (`<? ... ?>`) |
| `encryptchain` | `web::encryptd` | List of encrypt commands tried in sequence |
| `decryptchain` | `web::encryptd` | List of decrypt commands tried in sequence |
| `filepermissions` | 0644 | Permissions for log files, session files, temp files |
| `reset` | — | Resets all values to defaults |
| `version` | — | Returns version string (read-only) |
| `copyright` | — | Returns copyright string (read-only) |
| `script` | — | Path of currently requested script (read-only) |
| `server_root` | — | Apache ServerRoot (read-only) |
| `document_root` | — | Apache DocumentRoot (read-only) |
| `interpclass` | — | Current interpreter class (read-only) |

```tcl
web::config uploadfilesize [expr {8 * 1024 * 1024}]
web::config encryptchain {}    ;# disable URL encryption
web::config putxmarkup tag
```

---

## Command Dispatching

### `web::command`

```tcl
web::command ?cmdName? cmdBody
```

Registers `cmdBody` as `cmdName`. If `cmdName` is omitted, `"default"` is used.

### `web::getcommand`

```tcl
web::getcommand ?cmdName?
```

Returns body of `cmdName` (default: `"default"`).

### `web::dispatch`

```tcl
web::dispatch ?options?
```

Parses request and calls the matching command. Falls back to `"default"` if no command is found.

| Option | Description |
|--------|-------------|
| `-cmd cmdName` | Call `cmdName` directly (empty string: no command called) |
| `-querystring string` | Parse `string` as querystring (empty: disable querystring parsing) |
| `-postdata ""` | Do not parse POST data |
| `-postdata ?#?channel ?len? ?type?` | Parse channel (or var if `#`) as POST data |
| `-track paramKeyList` | Register params as static — included in every `web::cmdurl` |
| `-hook code` | Eval `code` just before the command, after full request parsing |

Supported content types for `-postdata`: `multipart/form-data; boundary=xxx`, `application/x-www-form-urlencoded`.

```tcl
web::command default { web::put "Hello" }
web::dispatch
```

### `web::cmdurl`

```tcl
web::cmdurl ?options? cmdName ?key-value-list?
web::cmdurl ?options? cmdName ?k1 v1 ... kN vN?
```

Generates self-referencing URLs with encrypted querystring.

| Option | Description |
|--------|-------------|
| `-notimestamp` | Omit timestamp from URL |
| `-urlformat list` | Which parts to include: `scheme host port scriptname pathinfo querystring` |

```tcl
web::cmdurl default
web::cmdurl -notimestamp page1 id 42
web::cmdurl -urlformat {scheme host scriptname querystring} myCmd
```

### `web::cmdurlcfg`

```tcl
web::cmdurlcfg ?option? ?key? ?value?
```

Configure `web::cmdurl` globally and manage static parameters.

| Option | Description |
|--------|-------------|
| `-scheme ?val?` | Protocol (default: from request) |
| `-host ?val?` | Hostname (default: from request) |
| `-port ?val?` | Port (default: from request) |
| `-scriptname ?val?` | Script name (default: from request) |
| `-pathinfo ?val?` | Path info (default: from request) |
| `-urlformat list` | Permanent URL format |
| `-set key val` | Add static parameter |
| `-names` | List static parameter names |
| `-unset ?key?` | Remove static parameter(s) |
| `-reset` | Reset URL config (not static params) |

---

## Request Data

### `web::request`

```tcl
web::request ?options? ?key? ?value?
web::request key ?default?
```

Access CGI environment / Apache request data.

| Subcommand | Description |
|------------|-------------|
| `key ?default?` | Get value for key; return default if missing |
| `-names` | List all known keys |
| `-count key` | Number of values for key |
| `-set key ?val...?` | Set/overwrite key |
| `-lappend key val...` | Append values to key |
| `-unset ?key?` | Delete key (or all keys) |
| `-reset` | Delete all request data, form vars, params, static params, temp files |
| `-channel` | Return default input channel |
| `AUTH_USER` | Username from Basic Auth header (when Apache doesn't handle auth) |
| `AUTH_PW` | Password from Basic Auth header |

Common keys: `REMOTE_ADDR`, `SERVER_NAME`, `REQUEST_METHOD`, `CONTENT_TYPE`, `CONTENT_LENGTH`, `HTTP_USER_AGENT`, `QUERY_STRING`, `CONTENT_DATA`, `CONTENT_ENCODING`, `AUTH_BEARER`.

### `web::param`

```tcl
web::param ?option? ?key? ?value...?
```

Access querystring parameters (after `web::dispatch`).

| Subcommand | Description |
|------------|-------------|
| `key ?default?` | Get value |
| `-names` | List all keys |
| `-count key` | Number of values for key |
| `-set key val...` | Set/overwrite |
| `-lappend key val...` | Append |
| `-unset ?key?` | Delete key (or all) |

### `web::formvar`

```tcl
web::formvar ?option? ?key? ?value?
```

Same interface as `web::param`. Access HTML form data (POST body after `web::dispatch`).

For file uploads, the value is a list: `{localFile remoteFile truncated mimeType}` where `truncated` is 0 (success), -1 (upload disabled), or n (bytes truncated).

---

## Response & Output

### `web::response`

```tcl
web::response
web::response option ?value?
web::response subcommand args
```

Manage HTTP response headers and response object selection.

| Subcommand/Option | Description |
|-------------------|-------------|
| *(no args)* | Return name of current response object |
| `-select ?#?channel` | Select channel as response object (`#` = global variable) |
| `-set key ?val?` | Set HTTP header field (e.g. `Content-Type text/html`) |
| `-lappend key val` | Append to header field |
| `-names` | List header keys |
| `-count key` | Number of values for key |
| `-unset ?key?` | Delete header(s) |
| `-sendheader ?bool?` | Get/set whether headers have been sent |
| `-httpresponse ?val?` | Get/set HTTP response line (e.g. `HTTP/1.0 200 OK`) |
| `-bytessent` | Bytes sent to channel so far |
| `-reset` | Reset headers, sendheader flag, HTTP response |
| `-resetall` | Reset all registered channels |
| `-flush` | Flush output buffer to network (mod_websh: calls `ap_rflush`) |

```tcl
web::response -set Content-Type "text/html; charset=utf-8"
web::response -set Status "401 Authorization Required"
web::response -set Set-Cookie "name=value; Path=/; HttpOnly"
```

### `web::put`

```tcl
web::put ?#channel? text
```

Send text to the current response channel. No newline added. `#channel` writes to a global variable.

### `web::putx`

```tcl
web::putx ?#channel? text
```

Like `web::put` but evaluates embedded Tcl code in `{...}` (or `<? ... ?>` with `web::config putxmarkup tag`). Escape braces with `\`.

```tcl
web::putx {<h1>{web::htmlify $title}</h1>}
```

### `web::putxfile`

```tcl
web::putxfile ?#channel? file ?msg?
```

Like `web::putx` but reads template from `file`. Returns 0 on success, 1 on error (error message written to `msg`).

---

## Logging

Two-step filtering: `web::loglevel` → `web::logdest`. No logging active by default.

Log levels (ascending severity): `alert`, `error`, `warning`, `info`, `debug`

Filter format: `tag.level` or `*.-level` (all tags, up to and including level).

### `web::log`

```tcl
web::log level msg
```

Issues a log message. Enable substitution with `web::config logsubst 1`.

### `web::loglevel`

```tcl
web::loglevel subcommand args
```

| Subcommand | Description |
|------------|-------------|
| `add level` | Add a filter level |
| `delete ?name?` | Remove level (or all) |
| `names` | List all level ids |
| `levels` | List all levels with detail |

```tcl
web::loglevel add *.-debug      ;# enable all up to debug
web::loglevel add myapp.-info   ;# enable info and above for tag "myapp"
```

`web::logfilter` is a compatibility alias for `web::loglevel` (Websh ≤ 3.5).

### `web::logdest`

```tcl
web::logdest subcommand ?options? args
```

| Subcommand | Description |
|------------|-------------|
| `add ?opts? level plugin ?plugin-opts?` | Add a log destination |
| `delete ?name?` | Remove destination (or all) |
| `names` | List destination ids |
| `levels` | List destinations with levels |

Options for `add`:
- `-maxchar n` — truncate message to n chars
- `-format "fmt"` — format string: `%x %X` (strftime), `$p` (PID), `$t` (thread), `$l` (level), `$n` (numeric level), `$f` (facility), `$m` (message), `$$` (dollar)
- Default format: `"%x %X [$p] $f.$l: $m\n"`

Plugins:

| Plugin | Syntax |
|--------|--------|
| `file` | `web::logdest add level file ?-unbuffered? filename` |
| `syslog` | `web::logdest add level syslog ?level?` (Unix only, typical level: 10) |
| `command` | `web::logdest add level command cmdName` |
| `channel` | `web::logdest add level channel ?-unbuffered? channel` |
| `apache` | `web::logdest add level apache` (mod_websh only) |

```tcl
web::loglevel add *.-debug
web::logdest add *.-debug syslog 10
web::logdest add *.-debug file /tmp/app.log
web::logdest add -format "--> \$m\n" *.-info channel stdout
```

---

## Context Management

### `web::context`

```tcl
web::context name
```

Creates namespace `name` with in-memory key-value store.

| Subcommand | Description |
|------------|-------------|
| `name::cset key val` | Set key |
| `name::cappend key val...` | Append to string value |
| `name::clappend key val...` | Append to list value |
| `name::cget key ?default?` | Get value (empty string if missing) |
| `name::cexists key` | Returns 1 if key exists |
| `name::cunset key` | Remove key |
| `name::carray option key ?arg?` | Array operations (like Tcl `array`) |
| `name::cnames ?pattern?` | List keys matching pattern |
| `name::delete` | Delete the context namespace |
| `name::dump` | Serialize context in sourceable format |

### `web::filecontext`

```tcl
web::filecontext name ?options?
```

File-based session context. Same data subcommands as `web::context` plus:

| Subcommand | Description |
|------------|-------------|
| `name::init ?id?` | Load existing session (or create new if idgen configured) |
| `name::new ?id?` | Create new session |
| `name::commit` | Persist session to file |
| `name::id` | Return session id |
| `name::invalidate` | Delete session from memory and filesystem |

Creation options:

| Option | Description |
|--------|-------------|
| `-perm perm` | File permissions (default: `web::config filepermissions`) |
| `-path path` | Path template (e.g. `/tmp/sess%s.dat`, `%s` = id) |
| `-crypt boolean` | Encrypt session file (default: on) |
| `-idgen cmd` | Command that returns new id (e.g. `fc nextval`) |
| `-attachto idparam` | Auto-load session id from `web::param idparam` |

### `web::cookiecontext`

```tcl
web::cookiecontext name ?options?
```

Cookie-based session context. Same subcommands as `web::filecontext`.

Creation options:

| Option | Description |
|--------|-------------|
| `-expires time` | Cookie expiry (seconds since epoch, time string, or `""` for no expiry; default: now+24h) |
| `-path path` | Cookie path |
| `-domain domain` | Cookie domain |
| `-secure boolean` | Secure flag |
| `-crypt boolean` | Encrypt cookie (default: on) |
| `-channel channelName` | Response channel for cookie |

### `web::filecounter`

```tcl
web::filecounter name -filename fname ?options?
```

Persistent numeric sequence generator.

Creation options: `-min val`, `-max val`, `-seed val`, `-incr val`, `-perms val`, `-wrap boolean`

| Subcommand | Description |
|------------|-------------|
| `name config` | Return configuration as flat key-value list |
| `name nextval` | Increment and return next value |
| `name curval` | Return current value (last `nextval` result) |
| `name getval` | Return current value from file (no increment) |

```tcl
web::filecounter fc -filename /tmp/session.cnt -min 1 -wrap 1
web::filecontext session -path /tmp/sess%s.dat -idgen "fc nextval" -crypt off
```

### `web::sessioncontextfactory`

```tcl
web::sessioncontextfactory ctxmgrname
```

Base factory for session context managers: creates a `web::context` and
adds the generic session methods (`init`, `new`, `id`, `commit`,
`invalidate`, plus `-idgen`/`-attachto` option parsing). `web::filecontext`
and `web::cookiecontext` build on it — application code normally uses
those instead of calling the factory directly.

### `web::filerandom`

```tcl
web::filerandom create name pathname
```

TclOO class: UUID-v4 id generator for `web::filecontext` (used by
`web::sessionSetup`). Persists the last issued UUID in `pathname/lastUUID`
and guarantees the id does not collide with an existing session file.

| Method | Description |
|--------|-------------|
| `name nextval` | Generate and persist a fresh UUID v4 |
| `name curval` | Last value returned by `nextval`/`getval` (no file read) |
| `name getval` | Read current value from file (no generation) |
| `name config` | Configuration as flat key-value list |

```tcl
set idgen [web::filerandom create new /tmp/sessions]
web::filecontext session -path /tmp/sessions/%s -idgen "$idgen nextval" -crypt off
```

### `web::genPasswd`

```tcl
web::genPasswd create name ?len?
name generate
name configure ?key? ?value?
```

TclOO class (package `genpasswd`, compiled in): random password
generator backed by `web::randombytes` (CSPRNG, rejection sampling —
no modulo bias) with a Fisher-Yates shuffle, suitable for real secrets.
Defaults: length 10 (constructor arg or `configure len n`; values < 4
fall back to 10) with at least one character from each class
(lower/upper/numbers/punctuation); ambiguous characters (`l`, `I`,
`O`, `0`) are excluded from the alphabets. `configure` without args
returns all rules (`len`, `lower,min`, `upper,min`, `numbers,min`,
`punctuation,min`); with key returns one; with key+value sets one.

---

## File I/O

### `web::include`

```tcl
web::include fileName ?msg?
```

Source Tcl script or load shared library. Returns 0 on success, 1 on error.

### `web::readfile`

```tcl
web::readfile file varName msg
```

Read `file` into variable `varName`. Returns 0 on success, 1 on error.

### `web::lockfile` / `web::unlockfile`

```tcl
web::lockfile fh
web::unlockfile fh
```

File locking via `lockf()`. `web::lockfile` also seeks to beginning of file. File must be open for writing.

### `web::truncatefile`

```tcl
web::truncatefile fh
```

Truncate file at current position (while holding lock).

### `web::tempfile`

```tcl
web::tempfile ?-path path? ?-prefix prefix?
web::tempfile -remove
```

Return unique temp filename (auto-deleted when interpreter exits). `-remove` deletes all previously created temp files now.

---

## Encoding / Decoding

### `web::htmlify`

```tcl
web::htmlify ?-numeric? text
```

Encode `<`, `>`, `&`, `"` and non-ASCII as HTML entities. `-numeric` uses `&#n;` form.

### `web::dehtmlify`

```tcl
web::dehtmlify text
```

Strip HTML tags and decode HTML entities.

### `web::uriencode`

```tcl
web::uriencode text
```

URL-encode text (space → `+`, special chars → `%xx`).

### `web::uridecode`

```tcl
web::uridecode text
```

Decode URL-encoded text.

```tcl
web::htmlify "<script>"          ;# → &lt;script&gt;
web::uriencode "Hello, world!"  ;# → Hello%2c+world%21
```

### `web::list2uri` / `web::uri2list`

```tcl
web::list2uri {k1 v1 k2 v2}     ;# → k1=v1&k2=v2 (uriencoded)
web::uri2list "k1=v1&k2=v2"     ;# → {k1 v1 k2 v2} (uridecoded)
```

Convert between an even-sized key/value list and a query string.
`list2uri` errors on odd-length lists.

---

## Encryption

Default encryption is weak (`web::encryptd`). Configure custom plugins via `web::config encryptchain`.

### `web::encrypt` / `web::decrypt`

```tcl
web::encrypt data
web::decrypt data
```

Encrypt/decrypt using current chain. Used for querystring encryption.

### `web::encryptd` / `web::decryptd`

```tcl
web::encryptd data
web::decryptd data
```

Built-in weak encrypt/decrypt (default plugin).

### `web::cryptdkey`

```tcl
web::cryptdkey ?key?
```

Set encryption key. No argument resets to default key. Does not return current key.

---

## Inter-Process Communication

### `web::send`

```tcl
web::send channel cmdNr message ?flags?
```

Send `cmdNr` and `message` to `channel`. `flags` is a list of symbolic flags (`multiple`/`noflush` = more to follow) or `#n` for numeric flags.

### `web::recv`

```tcl
web::recv channel cmdVarName msgVarName flagVarName
```

Receive from `channel`. Flags are returned numeric — use `web::msgflag` to interpret.

### `web::msgflag`

```tcl
web::msgflag                   ;# list all known flags
web::msgflag flags             ;# integer representation of flags
web::msgflag flags testflags   ;# 1 if testflags are set in flags
```

---

## Miscellaneous

### `web::match`

```tcl
web::match result listToBeSearched searchFor
```

Returns `result` if `searchFor` is in `listToBeSearched`, otherwise empty string.

```tcl
web::match "selected" {tv dvd vcr} dvd   ;# → selected
```

### `web::randombytes`

```tcl
web::randombytes n
web::randombytes names
web::randombytes source name
```

Return `n` cryptographically random bytes (binary). `names` lists available sources. `source` selects one.

---

## Apache Module Commands

These are no-ops in CGI mode (except `web::initializer`/`web::finalizer` which eval their code).

**Interpreter pool model.** `mod_websh` keeps a pool of persistent
interpreters. A `.ws3` file's top-level code runs **once per
interpreter, not per request**; `package require` is idempotent per
interp (package-load side effects fire once per fresh interp).
Consequences: put per-request logic in `web::command` /
`web::initializer`, not at top level; after changing a `.ws3` or a
package, run `apachectl -k graceful`; under CGI there is no pool —
every request gets a fresh interpreter and top-level code runs every
time.

### `web::initializer`

```tcl
web::initializer code
```

Code executed once when a new interpreter is created (not per request). `web::loglevel`/`web::logdest` calls here are persistent across requests.

### `web::finalizer`

```tcl
web::finalizer code
```

Register code to execute when the interpreter is deleted. Multiple calls stack (LIFO order).

### `web::finalize`

```tcl
web::finalize
```

Execute registered finalizer code (called automatically; can be renamed for hooks).

### `web::maineval`

```tcl
web::maineval code
```

Execute `code` in the "main" interpreter (synchronized/locked).

### `web::interpclasscfg`

```tcl
web::interpclasscfg classid property ?value?
```

| Property | Default | Description |
|----------|---------|-------------|
| `maxrequests` | 1 | Max requests per interpreter (0 = unlimited) |
| `maxttl` | 0 | Max lifetime in seconds (0 = forever) |
| `maxidletime` | 0 | Max idle seconds (0 = no timeout) |

### `web::interpcfg`

```tcl
web::interpcfg ?property? ?value?
```

| Property | Description |
|----------|-------------|
| *(no args)* | Return classid |
| `numreq` | Number of requests handled by this interpreter |
| `retire ?bool?` | Get/set retire-after-request flag |
| `starttime` | Epoch seconds when interpreter started |
| `lastusedtime` | Epoch seconds of last use |

### `web::interpmap`

```tcl
proc web::interpmap {filename} { return $filename }
```

Override to map requested files to interpreter classes. Must be defined in the WebshConfig file.

---

## Higher-Level Helpers (`webutils.tcl`)

### `web::getContent`

```tcl
web::getContent
```

Decode raw POST body correctly. Encoding priority: `charset=` from
Content-Type → *(JSON types without charset: `utf-8`, per RFC 8259)* →
`CONTENT_ENCODING` → `utf-8` fallback. JSON types are `application/json*`
and `*+json*`; without the JSON rule they would be mis-decoded as
`iso8859-1`, since the C layer always fills `CONTENT_ENCODING` with the
HTTP default. **Always use this instead of manual `encoding convertfrom`.**

### `web::mimeType`

```tcl
web::mimeType token
```

Map extension to MIME type: `json`, `pdf`, `png`, `jpg`, `svg`, `xlsx`, `docx`, `xml`, `csv`, `txt`, `zip`, `gz`, `bz2`, `bin`, `rtf`, `7z`, `ics`. Unknown tokens returned as-is.

### `web::returnJson`

```tcl
web::returnJson json
```

Send JSON response with `Content-Type: application/json`, correct `Content-Length`, no-cache headers, and UTF-8 encoding. Calls `web::response -reset` after.

### `web::returnText`

```tcl
web::returnText mimetype data ?encoding?
```

Send text response. `encoding` defaults to `utf-8`. Sets Content-Length, no-cache headers.

### `web::returnBinary`

```tcl
web::returnBinary mimetype data filename
```

Send binary response with `Content-Disposition: attachment`. Sets binary translation, Content-Length.

### `web::sseStart`

```tcl
web::sseStart
```

Set SSE headers (`Content-Type: text/event-stream`, `Cache-Control: no-cache`, `X-Accel-Buffering: no`) and disable buffering.

### `web::sseSend`

```tcl
web::sseSend data ?event? ?id? ?retry?
```

Send one SSE event and flush. Multiline `data` is split into multiple `data:` lines. Calls `web::response -flush`.

```tcl
web::sseStart
web::sseSend "Hello SSE"
web::sseSend $payload myEvent $id
web::put ": keepalive\n"    ;# prevent proxy timeout
web::response -flush
```

#### ⚠️ Non-ASCII bytes kill the stream

When `data` contains any byte > 0x7F (German `ä`/`ö`/`ü`, any UTF-8
multi-byte sequence, …), the **first** such `web::sseSend` reproducibly
fails with:

```
websh.error: web::put: error writing to response object
```

The browser EventSource sees a TCP reset and fires `onerror`. Even `curl
--no-buffer` cuts off at the same line. Forcing the response channel to
`-encoding utf-8` (e.g. via a `dispatch -hook`) is **not enough** —
under `web::sseSend` → `web::put` → `ap_rwrite`, the write still fails
for the multi-byte case (root cause not pinned down in the Tcl layer;
reproducible on Apache 2.4.67 + OpenSSL 3.6.2 on macOS).

**Workaround**: set the response channel to `-encoding binary` and
produce UTF-8 bytes yourself with `encoding convertto utf-8`; write them
via `web::put` so Tcl doesn't apply a second encoding pass:

```tcl
proc myapp::sseStart {} {
    web::sseStart
    catch {fconfigure [web::request -channel] -encoding binary -translation lf}
}

proc myapp::sseSendLine {data {event {}}} {
    set bytes [encoding convertto utf-8 $data]
    if {$event ne {}} {
        web::put "event: $event\ndata: $bytes\n\n"
    } else {
        web::put "data: $bytes\n\n"
    }
    web::response -flush
}
```

Use the helper everywhere the payload may contain non-ASCII characters
— including for `event: done`-style terminators. Pure-ASCII streams can
keep using `web::sseSend`; the bug only triggers when a byte > 0x7F
actually hits the wire.

**Diagnostic signature**: N ASCII lines arrive cleanly on the wire
(curl prints them, browser sees them in order), then the write of the
first multi-byte payload fails and the connection drops. Any subprocess
the stream was relaying keeps running fine — it's purely a display
problem on the response side.

**Idealfix**: `webutils.tcl::web::sseSend` should internally
`encoding convertto utf-8` the `data` argument and write through a
byte-identity path. Then the user-space workaround can be removed.

### `web::uuidV4`

```tcl
web::uuidV4
```

Generate RFC 4122 UUID v4 (uses `web::randombytes`).

### `web::ts`

```tcl
web::ts ?ms?
```

Format millisecond timestamp as `2024-01-15T14:30:00.123`. Without argument uses `clock milliseconds`.

---

## JWT — separate package (since websh 3.7.8)

JWT support is **not part of websh anymore**. The former embedded `jwt`
package lives on as the standalone pure-Tcl package **`jwt` 1.1**
(BSD-3, `~/src/jwt`, installed under `/opt/tcl/<ver>/lib/jwt1.1`;
requires the C packages `nacl` and `rl_json` at runtime):

```tcl
package require jwt
::jwt::sign header payload secret
::jwt::verify token secret ?-json? ?-claims? ?-leeway sec?
::jwt::base64url_encode / ::jwt::base64url_decode
```

Full API documentation: README of the jwt package. websh itself no
longer depends on `nacl`/`rl_json`.

---

## Session Helpers (`webutils.tcl`)

These helpers implement a file-based session pattern with JWT-style claims.

### `web::configSetup`

```tcl
web::configSetup ?context?
```

Create config context (default: `::config`). `config::cset path /tmp/sessions` etc.

### `web::sessionSetup`

```tcl
web::sessionSetup ?context?
```

Create session context (default: `::session`) using UUID v4 idgen. Requires `web::configSetup` first.

### `web::sessionNew`

```tcl
web::sessionNew ?timeout? ?subject? ?audience? ?maxlifetime?
```

Create new session. `timeout` in ms (default: 3600000). Sets `X-Session` response header with JWT claims. Returns session id.

### `web::sessionInit`

```tcl
web::sessionInit ?uuid?
```

Load session by id. If `uuid` is given it wins over the `AUTH_BEARER` request header — use this whenever the request authenticates with something other than the refresh-jti (e.g. an access-JWT whose claims carry the session id) and you want to load a known session by id. Without `uuid` the id is taken from the `AUTH_BEARER` request header (the usual case). Returns `true`/`false`. Checks expiry and `sessionClosed` flag.

### `web::sessionClose`

```tcl
web::sessionClose
```

Mark session as closed, commit, set `X-Status: sessionClosed`. Returns session claims dict.

### `web::sessionRefresh`

```tcl
web::sessionRefresh ?timeout?
```

Extend session expiry. Returns updated claims dict.

### `web::sessionGet`

```tcl
web::sessionGet
```

Return current session claims as dict: `iss sub aud exp nbf iat jti mlt`.

### `web::loggingSetup`

```tcl
web::loggingSetup level ?syslog?
```

Configure syslog logging with session tag in format string.

> **`loggingSetup` only wires the syslog destination.** Under
> `mod_websh`, `web::log` does **not** appear in the Apache vHost error
> log unless the `apache` destination is additionally registered:
>
> ```tcl
> web::loggingSetup *.-debug
> catch {web::logdest add *.-debug apache}   ;# mod_websh only
> ```
>
> The `catch` is required because the `apache` destination does not
> exist under CGI/`tclsh`. On macOS syslog is effectively invisible, so
> the `apache` destination is usually the only practical sink there.

---

## Typical Application Structure

```tcl
# Under mod_websh and the websh binary, all web::* commands are built in —
# no package require needed. In a plain tclsh use: package require websh

web::config uploadfilesize [expr {8 * 1024 * 1024}]
web::config encryptchain {}

web::loglevel add *.-debug
web::logdest add *.-debug syslog 10

web::command default {
    web::response -set Content-Type "text/html; charset=utf-8"
    web::put "<html><body>"
    web::put "<p>Hello [web::htmlify [web::param name]]</p>"
    web::put "<a href=[web::cmdurl page1]>Next</a>"
    web::put "</body></html>"
}

web::command page1 {
    web::returnJson "{\"status\":\"ok\"}"
}

web::dispatch
```

## Important Notes

- `web::response -set` sets headers (not `-header` — that subcommand does not exist)
- `web::putx` braces are eval'd: `{web::put $var}` — escape with `\{`
- Multipart text fields from `web::formvar` are correctly UTF-8 decoded
- Use `web::getContent` for raw POST body, never `web::request CONTENT_DATA` directly
- `web::response -flush` works in both CGI (Tcl flush) and mod_websh (`ap_rflush`)
- `web::config encryptchain {}` disables URL querystring encryption
