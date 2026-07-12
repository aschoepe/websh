/*
 * tclAppInit.c --
 *
 *	Provides a default version of the main program and Tcl_AppInit
 *	procedure for the websh shell (without Tk).
 *
 * Copyright (c) 1993 The Regents of the University of California.
 * Copyright (c) 1994-1997 Sun Microsystems, Inc.
 * Copyright (c) 1998-2000 by Scriptics Corporation.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include "webtclcompat.h"
#include "web.h"

/* Tcl 8.6's tcl.h declares Tcl_AppInit itself; this matches it and
 * provides the declaration for Tcl 9 (where it is gone). */
extern Tcl_AppInitProc Tcl_AppInit;

/*
 *----------------------------------------------------------------------
 *
 * main --
 *
 *	This is the main program for the application.
 *
 * Results:
 *	None: Tcl_Main never returns here, so this procedure never
 *	returns either.
 *
 *----------------------------------------------------------------------
 */

int main(int argc, char **argv)
{
    Tcl_Main(argc, argv, Tcl_AppInit);
    return 0;			/* Needed only to prevent compiler warning. */
}

/*
 *----------------------------------------------------------------------
 *
 * Tcl_AppInit --
 *
 *	This procedure performs application-specific initialization.
 *
 * Results:
 *	Returns a standard Tcl completion code, and leaves an error
 *	message in the interp's result if an error occurs.
 *
 *----------------------------------------------------------------------
 */

int Tcl_AppInit(Tcl_Interp *interp)
{
    if (Tcl_InitStubs(interp, "8.6-", 0) == NULL) {
	return TCL_ERROR;
    }

    if (Tcl_Init(interp) == TCL_ERROR) {
	return TCL_ERROR;
    }

    if (Websh_Init(interp) == TCL_ERROR) {
	return TCL_ERROR;
    }

    /*
     * Specify a user-specific startup file to invoke if the application
     * is run interactively.
     */

    Tcl_SetVar2(interp, "tcl_rcFileName", NULL, "~/.tclshrc", TCL_GLOBAL_ONLY);
    return TCL_OK;
}
