/*
 * logtoap.h --
 * nca-073-9
 *
 * Copyright (c) 1996-2000 by Netcetera AG.
 * Copyright (c) 2001 by Apache Software Foundation.
 * All rights reserved.
 *
 * See the file "license.terms" for information on usage and
 * redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * @(#) $Id: logtoap.h 322184 2002-03-06 15:35:01Z ronnie $
 *
 */

#ifndef WEB_LOGTOAP_H
#define WEB_LOGTOAP_H

/* ----------------------------------------------------------------------------
 * plugin logger: toAp
 * ------------------------------------------------------------------------- */
typedef struct LogToApData
{
    int dum;
}
LogToApData;
LogToApData *createLogToApData();
int destroyLogToApData(Tcl_Interp * interp, LogToApData * logToApData);

ClientData createLogToAp(Tcl_Interp * interp, ClientData clientData,
			 int objc, Tcl_Obj * CONST objv[]);
int destroyLogToAp(Tcl_Interp * interp, ClientData clientData);
/* buffer for the formatted message of logToApFmt */
#define LOGTOAP_FMT_BUFSIZE 2048

#if defined(__GNUC__) || defined(__clang__)
#define LOGTOAP_PRINTF(fmtIdx, argIdx) __attribute__((format(printf, fmtIdx, argIdx)))
#else
#define LOGTOAP_PRINTF(fmtIdx, argIdx)
#endif

/* log handler (LogPlugInHandler): msg is logged verbatim, never as format */
int logToAp(Tcl_Interp * interp, ClientData clientData, char *msg);
/* printf-style variant for mod_websh's own messages; fmt must be a literal */
int logToApFmt(Tcl_Interp * interp, ClientData clientData, const char *fmt, ...)
    LOGTOAP_PRINTF(3, 4);

#endif
