# Server-Sent Events (SSE) Example for websh 3.7.3

## Files

- `sse-dispatch.ws3` — SSE server using `web::command` / `web::dispatch`
- `sse-client.html` — Browser client
- `README.md` — This file

## SSE API

### `web::sseStart`

Sets `Content-Type: text/event-stream`, disables output buffering. Call once at the
top of the command body, before any `web::sseSend`.

### `web::sseSend data ?event? ?id? ?retry?`

Sends one SSE event and flushes immediately. Multiline `data` is split into
separate `data:` lines automatically.

```tcl
web::sseSend "Hello"                           ;# unnamed message
web::sseSend "{\"step\":1}" progress 42        ;# named event with id
web::sseSend "Line 1\nLine 2" multiline 43     ;# multiline data
```

### `web::response -flush`

Explicit flush — called internally by `web::sseSend`. Available for keepalive
comments between events:

```tcl
web::put ": keepalive\n"
web::response -flush
```

## Example: `sse-dispatch.ws3`

Two commands, selectable via the `command` query parameter:

| URL | What it does |
|-----|--------------|
| `sse-dispatch.ws3?command=sse` | 5 progress steps, 1.5 s apart, then `done` |
| `sse-dispatch.ws3?command=sseRun&job=X` | 3-phase job with client-disconnect detection |

Pattern used in both commands:

```tcl
web::command myJob {
    web::sseStart                              ;# once, at the start

    if {[catch {
        # ... do work ...
        web::sseSend $data progress $eventId   ;# flush after each step

        web::sseSend $result done $eventId     ;# signal completion
    } err]} {
        web::log error "SSE client disconnect: $err"
    }
}

web::dispatch
```

The `catch` block handles client disconnects: `web::sseSend` throws when the
connection is gone, stopping the job immediately.

## Deployment

### mod_websh (Apache)

```apache
<Directory "/path/to/sse">
    SetHandler websh
    DirectoryIndex sse-client.html
</Directory>
```

### CGI

```bash
chmod +x sse-dispatch.ws3
```

Configure Apache/nginx to execute `.ws3` files as CGI.
