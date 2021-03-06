/*
 * cryp.h --- encryption by use of plug-Ins
 * nca-073-9
 * 
 * Copyright (c) 1996-2000 by Netcetera AG.
 * Copyright (c) 2001 by Apache Software Foundation.
 * All rights reserved.
 *
 * See the file "license.terms" for information on usage and
 * redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * @(#) $Id: crypt.h 384862 2006-03-10 17:28:35Z ronnie $
 *
 */

#include <tcl.h>
#include "webutl.h"

#ifndef CRYPT_H
#define CRYPT_H

#define WEB_CRYPT_ASSOC_DATA  "web::crypt"
#define WEB_ENCRYPTDEFAULT "web::encryptd"
#define WEB_DECRYPTDEFAULT "web::decryptd"


/* ----------------------------------------------------------------------------
 * crypt data structure
 * ------------------------------------------------------------------------- */
typedef struct CryptData
{
    Tcl_Obj *encryptChain;
    Tcl_Obj *decryptChain;
}
CryptData;
CryptData *createCryptData();
void destroyCryptData(ClientData clientData, Tcl_Interp * interp);

/* ----------------------------------------------------------------------------
 * Tcl interface and commands
 * ------------------------------------------------------------------------- */
int crypt_Init(Tcl_Interp * interp);

int Web_Encrypt(ClientData clientData,
		Tcl_Interp * interp, int objc, Tcl_Obj * CONST objv[]);

int Web_Decrypt(ClientData clientData,
		Tcl_Interp * interp, int objc, Tcl_Obj * CONST objv[]);

/* ----------------------------------------------------------------------------
 * C API
 * ------------------------------------------------------------------------- */
int doencrypt(Tcl_Interp * interp, Tcl_Obj * in, int internal);
int dodecrypt(Tcl_Interp * interp, Tcl_Obj * in, int internal);

#endif
