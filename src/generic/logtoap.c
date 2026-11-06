/*
 * logtoap.c -- log to apache error log
 * nca-073-9
 * 
 * Copyright (c) 1996-2000 by Netcetera AG.
 * Copyright (c) 2001 by Apache Software Foundation.
 * All rights reserved.
 *
 * See the file "license.terms" for information on usage and
 * redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * @(#) $Id: logtoap.c 322196 2002-03-07 18:55:40Z davidw $
 *
 */

#include "args.h"
#include "logtoap.h"
#include "macros.h"
#include "mod_websh.h"
#include "tcl.h"
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

/* ----------------------------------------------------------------------------
 * createLogToApData --
 * ------------------------------------------------------------------------- */
LogToApData *createLogToApData()
{

    return NULL;
}

/* ----------------------------------------------------------------------------
 * destroyLogToApData --
 * ------------------------------------------------------------------------- */
int destroyLogToApData(Tcl_Interp * interp, LogToApData * logToApData)
{

    return TCL_OK;
}

/* ----------------------------------------------------------------------------
 * constructor -- initializes internal data for "logToAp".
 * Called by "web::logbag add channel chName".
 * ------------------------------------------------------------------------- */
ClientData createLogToAp(Tcl_Interp * interp, ClientData clientData,
			 int objc, Tcl_Obj * CONST objv[])
{

    /* --------------------------------------------------------------------------
     * syntax is: apache
     *            0    1             2
     * ----------------------------------------------------------------------- */
    if (objc != 1) {
	Tcl_WrongNumArgs(interp, 0, objv, "");
	return NULL;
    }

    return (ClientData) 1;
}


/* ----------------------------------------------------------------------------
 * destructor
 * ------------------------------------------------------------------------- */
int destroyLogToAp(Tcl_Interp * interp, ClientData clientData)
{
    return TCL_OK;
}

/* ----------------------------------------------------------------------------
 * logToAp -- log handler of the "apache" destination.
 *
 * msg is the complete, already formatted log message. It may contain
 * anything, including data supplied by the client (web::log of a header
 * value, a user name, ...), so it must reach the Apache log function as an
 * argument of a fixed "%s" format and never as the format string itself.
 * ------------------------------------------------------------------------- */
int logToAp(Tcl_Interp * interp, ClientData clientData, char *msg)
{

    request_rec *r = NULL;

    if ((interp == NULL) || (msg == NULL))
	return TCL_ERROR;

    r = (request_rec *) Tcl_GetAssocData(interp, WEB_AP_ASSOC_DATA, NULL);

    if (r != NULL)
	if (r->server != NULL)
#ifndef APACHE2
	    ap_log_printf(r->server, "%s", msg);
#else /* APACHE2 */
	    ap_log_rerror(APLOG_MARK, APLOG_NOERRNO | APLOG_ERR, 0, r, "%s", msg);
#endif /* APACHE2 */

    return TCL_OK;
}

/* ----------------------------------------------------------------------------
 * logToApFmt -- printf-style variant for mod_websh's own messages
 * (interpool.c). The arguments are formatted here, the result is logged
 * verbatim through logToAp. fmt must be a string literal.
 * ------------------------------------------------------------------------- */
int logToApFmt(Tcl_Interp * interp, ClientData clientData, const char *fmt, ...)
{

    char buf[LOGTOAP_FMT_BUFSIZE];
    va_list args;

    if ((interp == NULL) || (fmt == NULL))
	return TCL_ERROR;

    va_start(args, fmt);
    vsnprintf(buf, sizeof(buf), fmt, args);
    va_end(args);

    return logToAp(interp, clientData, buf);
}
