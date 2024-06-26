/*
 * request_ap.c -- get request data from apaches request object
 * nca-073-9
 *
 * Copyright (c) 1996-2000 by Netcetera AG.
 * Copyright (c) 2001 by Apache Software Foundation.
 * All rights reserved.
 *
 * See the file "license.terms" for information on usage and
 * redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * @(#) $Id: response_ap.c 777449 2009-05-22 10:13:35Z ronnie $
 *
 */

#include "tcl.h"
#include "hashutl.h"
#include "webutl.h"

#include "mod_websh.h"
#include "webout.h"

#include "request.h"

#ifdef APACHE2
#include "apr_strings.h"
#endif

/* ----------------------------------------------------------------------------
 * apHeaderHandler -- set headers in mod_websh case
 * ------------------------------------------------------------------------- */
int apHeaderHandler(Tcl_Interp * interp, ResponseObj * responseObj,
		    Tcl_Obj * out)
{

    Tcl_Obj *httpResponse = NULL;
    request_rec *r = NULL;

    /* --------------------------------------------------------------------------
     * sanity
     * ----------------------------------------------------------------------- */
    if ((interp == NULL) || (responseObj == NULL))
	return TCL_ERROR;
    if (responseObj->sendHeader == 1) {

	HashTableIterator iterator;
	char *key;
	Tcl_Obj *headerList;

	r = (request_rec *) Tcl_GetAssocData(interp, WEB_AP_ASSOC_DATA, NULL);
	if (r == NULL) {
	    Tcl_SetResult(interp, "error accessing httpd request object",
			  NULL);
	    return TCL_ERROR;
	}

	httpResponse = responseObj->httpresponse;
	if (httpResponse != NULL) {

	  /* note: looks like this is the only way to set a status line in ap
	   * - still looking for better solutions, though */

	  /* 404 not found */
	  char *response = strchr(Tcl_GetString(httpResponse), (int) ' ');
	  /* _not found */
#ifndef APACHE2
	  if (response) {
	      /* not found */
		r->status_line = ap_pstrdup(r->pool, ++response);
          }
#else /* APACHE2 */
	  if (response) {
		r->status_line = (char *) apr_pstrdup(r->pool, ++response);
          }
		/* as of Apache 2.2.1, r->status_line must be in line with
		   r->status, therefore r->status must be set too */
		if (strlen(response) > 3) {
		  /* status code must be 3 digit numeric, which is supposed
		     to be followed by a blank in the status line */
		  char tmp = response[3];
		  response[3] = 0;
		  Tcl_GetInt(interp, response, &(r->status));
		  response[3] = tmp;
		}
		
#endif /* APACHE2 */
	}
	assignIteratorToHashTable(responseObj->headers, &iterator);
	while (nextFromHashIterator(&iterator) != TCL_ERROR) {
	    key = keyOfCurrent(&iterator);
	    if (key != NULL) {
		headerList = (Tcl_Obj *) valueOfCurrent(&iterator);
		if (headerList != NULL) {
		    int lobjc = -1;
		    Tcl_Obj **lobjv = NULL;
		    int i;
		    if (Tcl_ListObjGetElements(interp, headerList,
					       &lobjc, &lobjv) == TCL_ERROR) {
			LOG_MSG(interp, WRITE_LOG,
				__FILE__, __LINE__,
				"web::put", WEBLOG_ERROR,
				(char *) Tcl_GetStringResult(interp), NULL);
			return TCL_ERROR;
		    }

		    if (lobjc) {
#ifndef APACHE2
		      if (STRCASECMP(key, "Content-Type") == 0) {
			r->content_type =
			  ap_pstrdup(r->pool, Tcl_GetString(lobjv[0]));
		      } else {
			ap_table_set(r->headers_out,
				     key,
				     Tcl_GetString(lobjv[0]));
			for (i = 1; i < lobjc; i++) {
			  ap_table_add(r->headers_out,
				       key,
				       Tcl_GetString(lobjv[i]));
			}
		      }
#else /* APACHE2 */
		      if (STRCASECMP(key, "Content-Type") == 0) {
			r->content_type =
			  (char *) apr_pstrdup(r->pool, Tcl_GetString(lobjv[0]));
		      } else {
			apr_table_set(r->headers_out,
				      key,
				      Tcl_GetString(lobjv[0]));
			for (i = 1; i < lobjc; i++) {
			  apr_table_add(r->headers_out,
					key,
					Tcl_GetString(lobjv[i]));
			}
		      }
#endif /* APACHE2 */
		    }
		}
	    }
	}
#ifndef APACHE2
	ap_send_http_header(r);
#else /* APACHE2 */
	/* not needed in ap 2.0 anymore (according to Justin Erenkrantz) */
	/* ap_send_http_header(r); */
#endif /* APACHE2 */
	responseObj->sendHeader = 0;
    }
    return TCL_OK;
}

/* ----------------------------------------------------------------------------
 * createDefaultResponseObj
 * ------------------------------------------------------------------------- */
ResponseObj *createDefaultResponseObj_AP(Tcl_Interp * interp)
{
    return createResponseObj(interp, APCHANNEL, &apHeaderHandler);
}

/* ----------------------------------------------------------------------------
 * isDefaultResponseObj
 * ------------------------------------------------------------------------- */
int isDefaultResponseObj_AP(Tcl_Interp * interp, char *name)
{
    return !strcmp(name, APCHANNEL);
}
