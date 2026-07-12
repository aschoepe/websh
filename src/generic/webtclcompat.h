/*
 * webtclcompat.h -- Tcl 8.6 / Tcl 9 compatibility shims
 *
 * See the file "license.terms" for information on usage and
 * redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * Tcl 9 changed all length/index out-parameters from int to Tcl_Size
 * (TIP 660). Building against Tcl <= 8.6 lacks the type and the
 * companion macros; define them so the code base can use Tcl_Size
 * unconditionally. Macro block as recommended by
 * https://core.tcl-lang.org/tcl/wiki?name=Migrating+C+extensions+to+Tcl+9
 */

#ifndef WEBTCLCOMPAT_H
#define WEBTCLCOMPAT_H

#include <tcl.h>
#include <limits.h>

#ifndef TCL_SIZE_MAX		/* Tcl <= 8.6 */
#  define Tcl_GetSizeIntFromObj Tcl_GetIntFromObj
#  define TCL_SIZE_MAX INT_MAX
#  ifndef Tcl_Size
typedef int Tcl_Size;
#  endif
#  define TCL_SIZE_MODIFIER ""
#endif

/*
 * Tcl 9 removed Tcl_GetByteArrayFromObj's silent string->bytes
 * coercion: it returns NULL when the value contains characters
 * > U+00FF. Callers must handle NULL on both versions.
 */

#endif /* WEBTCLCOMPAT_H */
