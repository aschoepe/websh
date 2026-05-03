#!/bin/bash -norc
#
# configure.ac -- configure for websh (TEA-based)
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

#--------------------------------------------------------------------
# Package name and version. TEA derives PKG_LIB_FILE from these.
#--------------------------------------------------------------------

AC_INIT([websh],[3.7.4])

TEA_INIT()

AC_CONFIG_AUX_DIR(tclconfig)

# Backward-compatibility substitutions used in Makefile.in
VERSION=$PACKAGE_VERSION
PACKAGE=$PACKAGE_NAME
AC_SUBST(VERSION)
AC_SUBST(PACKAGE)

#--------------------------------------------------------------------
# Load tclConfig.sh
#--------------------------------------------------------------------

TEA_PATH_TCLCONFIG
TEA_LOAD_TCLCONFIG

TEA_PREFIX

#--------------------------------------------------------------------
# Compiler setup — replaces SC_ENABLE_GCC + AC_PROG_CC + AC_PROG_INSTALL
#--------------------------------------------------------------------

TEA_SETUP_COMPILER

#--------------------------------------------------------------------
# strcasecmp (required by STRCASECMP macro in webutl.h)
#--------------------------------------------------------------------

AC_EGREP_HEADER(strcasecmp, string.h, tcl_ok=1, tcl_ok=0)
if test $tcl_ok = 0; then
    AC_EGREP_HEADER(strcasecmp, strings.h, tcl_ok=1, tcl_ok=0)
    if test $tcl_ok = 0; then
        AC_MSG_ERROR([strcasecmp not found on this system])
    fi
fi

#--------------------------------------------------------------------
# Platform symbol (-DSYSV=1, -DWIN32=1, etc.)
#--------------------------------------------------------------------

case "`uname -s`" in
    *win32* | *WIN32* | *CYGWIN_NT*)  PLATFORM="WIN32"   ;;
    *aix*   | *AIX*)                  PLATFORM="AIX"     ;;
    *freebsd* | *FreeBSD*)            PLATFORM="FREEBSD" ;;
    *bsd/os* | *BSD/OS*)              PLATFORM="BSDI"    ;;
    *)                                PLATFORM="SYSV"    ;;
esac
AC_SUBST(PLATFORM)

#--------------------------------------------------------------------
# Optional Apache module
#
#   (default)          auto-detect: enable if httpd.h is found
#   --enable-apache    require Apache headers; fail if absent
#   --disable-apache   skip mod_websh unconditionally
#--------------------------------------------------------------------

AC_ARG_ENABLE([apache],
    AS_HELP_STRING([--enable-apache],[build mod_websh Apache module (default: auto)]),
    [enable_apache=${enableval}], [enable_apache=check])

HTTPD_INCLUDES=
HTTPD_BIN=
APR_INCLUDES=
APU_INCLUDES=
APR_LIB=
APU_LIB=
APACHE_TARGET=
INSTALL_APACHE=

if test "${enable_apache}" != "no"; then

    # On macOS, detect the active Homebrew prefix (Intel: /usr/local, Apple Silicon: /opt/homebrew)
    BREW_PREFIX=
    if test "`uname -s`" = "Darwin"; then
        BREW_PREFIX=`brew --prefix 2>/dev/null`
    fi

    AC_MSG_CHECKING([for httpd header files])
    AC_ARG_WITH([httpdinclude],
        AS_HELP_STRING([--with-httpdinclude=DIR],[directory containing Apache header files]),
        [with_httpdinclude=${withval}], [with_httpdinclude=NA])

    found_httpd=no
    if test "x${with_httpdinclude}" != "xNA"; then
        if test -f "${with_httpdinclude}/httpd.h"; then
            HTTPD_INCLUDES="-I${with_httpdinclude}"
            HTTPD_INCDIR="${with_httpdinclude}"
            found_httpd=yes
            AC_MSG_RESULT([${with_httpdinclude}])
        else
            AC_MSG_ERROR([${with_httpdinclude}: does not contain httpd.h])
        fi
    else
        # Build search list: standard paths + Homebrew paths (Darwin)
        httpd_search="/usr/local/include /usr/include \
                      /usr/include/httpd /usr/include/apache2 \
                      /usr/include/apache /usr/include/httpd2"
        if test -n "${BREW_PREFIX}"; then
            httpd_search="${httpd_search} \
                ${BREW_PREFIX}/opt/httpd/include/httpd \
                ${BREW_PREFIX}/include/httpd"
        fi
        for i in ${httpd_search}; do
            if test -f "$i/httpd.h"; then
                HTTPD_INCLUDES="-I$i"
                HTTPD_INCDIR="$i"
                found_httpd=yes
                AC_MSG_RESULT([$i])
                break
            fi
        done
    fi

    if test "${found_httpd}" = "no"; then
        if test "${enable_apache}" = "yes"; then
            AC_MSG_ERROR([httpd.h not found. Use --with-httpdinclude=DIR or --disable-apache])
        else
            AC_MSG_RESULT([not found — skipping mod_websh])
        fi
    else
        # Darwin: locate httpd binary (needed for -bundle_loader)
        if test "`uname -s`" = "Darwin"; then
            AC_MSG_CHECKING([for httpd binary])
            AC_ARG_WITH([httpd],
                AS_HELP_STRING([--with-httpd=BIN],[Apache binary (Darwin only)]),
                [with_httpd=${withval}], [with_httpd=NA])
            if test "x${with_httpd}" != "xNA"; then
                test -f "${with_httpd}" || AC_MSG_ERROR([httpd binary not found: ${with_httpd}])
                HTTPD_BIN="${with_httpd}"
                AC_MSG_RESULT([${with_httpd}])
            else
                HTTPD_BIN=
                # Try: relative to include dir, Homebrew, PATH
                brew_httpd_bin=
                test -n "${BREW_PREFIX}" && brew_httpd_bin="${BREW_PREFIX}/opt/httpd/bin/httpd"
                for candidate in "${HTTPD_INCDIR}/../bin/httpd" \
                                 "${brew_httpd_bin}" \
                                 "`which httpd 2>/dev/null`"; do
                    if test -f "${candidate}"; then
                        HTTPD_BIN="${candidate}"
                        AC_MSG_RESULT([${candidate}])
                        break
                    fi
                done
                test -n "${HTTPD_BIN}" || \
                    AC_MSG_ERROR([httpd binary not found. Use --with-httpd=BIN])
            fi
        fi

        # APR headers — auto-detect via apr-1-config (system or Homebrew), override with --with-aprinclude
        AC_ARG_WITH([aprinclude],
            AS_HELP_STRING([--with-aprinclude=DIR],[directory containing APR header files]),
            [with_aprinclude=${withval}], [with_aprinclude=NA])
        if test "x${with_aprinclude}" != "xNA"; then
            test -f "${with_aprinclude}/apr.h" || \
                AC_MSG_ERROR([${with_aprinclude}: does not contain apr.h])
            APR_INCLUDES="-I${with_aprinclude}"
        else
            AC_MSG_CHECKING([for APR include path])
            apr_cfg=`which apr-1-config 2>/dev/null`
            if test -z "${apr_cfg}" && test -n "${BREW_PREFIX}"; then
                apr_cfg="${BREW_PREFIX}/opt/apr/bin/apr-1-config"
                test -f "${apr_cfg}" || apr_cfg=
            fi
            if test -n "${apr_cfg}"; then
                apr_includes=`${apr_cfg} --includes 2>/dev/null`
            fi
            if test -n "${apr_includes}"; then
                APR_INCLUDES="${apr_includes}"
                AC_MSG_RESULT([${apr_includes}])
            else
                AC_MSG_RESULT([not found — apr-1-config missing, try --with-aprinclude=DIR])
            fi
        fi

        # APU headers — auto-detect via apu-1-config (system or Homebrew), override with --with-apuinclude
        AC_ARG_WITH([apuinclude],
            AS_HELP_STRING([--with-apuinclude=DIR],[directory containing APR-util header files]),
            [with_apuinclude=${withval}], [with_apuinclude=NA])
        if test "x${with_apuinclude}" != "xNA"; then
            test -f "${with_apuinclude}/apr_hooks.h" || \
                AC_MSG_ERROR([${with_apuinclude}: does not contain apr_hooks.h])
            APU_INCLUDES="-I${with_apuinclude}"
        else
            AC_MSG_CHECKING([for APU include path])
            apu_cfg=`which apu-1-config 2>/dev/null`
            if test -z "${apu_cfg}" && test -n "${BREW_PREFIX}"; then
                apu_cfg="${BREW_PREFIX}/opt/apr-util/bin/apu-1-config"
                test -f "${apu_cfg}" || apu_cfg=
            fi
            if test -n "${apu_cfg}"; then
                apu_includes=`${apu_cfg} --includes 2>/dev/null`
            fi
            if test -n "${apu_includes}"; then
                APU_INCLUDES="${apu_includes}"
                AC_MSG_RESULT([${apu_includes}])
            else
                AC_MSG_RESULT([not found — apu-1-config missing, try --with-apuinclude=DIR])
            fi
        fi

        if test "`uname -s`" = "Darwin"; then shlibext=dylib; else shlibext=so; fi

        # APR library
        AC_ARG_WITH([apr],
            AS_HELP_STRING([--with-apr=DIR],[directory containing APR library]),
            [with_apr=${withval}], [with_apr=NA])
        if test "x${with_apr}" != "xNA"; then
            test -f "${with_apr}/libapr-1.${shlibext}" || \
                AC_MSG_ERROR([${with_apr}: does not contain libapr-1.${shlibext}])
            APR_LIB="-L\"${with_apr}\" -lapr-1"
        fi

        # APU library
        AC_ARG_WITH([apu],
            AS_HELP_STRING([--with-apu=DIR],[directory containing APR-util library]),
            [with_apu=${withval}], [with_apu=NA])
        if test "x${with_apu}" != "xNA"; then
            test -f "${with_apu}/libaprutil-1.${shlibext}" || \
                AC_MSG_ERROR([${with_apu}: does not contain libaprutil-1.${shlibext}])
            APU_LIB="-L\"${with_apu}\" -laprutil-1"
        fi

        APACHE_TARGET="mod_websh.so"
        INSTALL_APACHE="install-libraries"
    fi
fi

AC_SUBST(HTTPD_INCLUDES)
AC_SUBST(HTTPD_BIN)
AC_SUBST(APR_INCLUDES)
AC_SUBST(APU_INCLUDES)
AC_SUBST(APR_LIB)
AC_SUBST(APU_LIB)
AC_SUBST(APACHE_TARGET)
AC_SUBST(INSTALL_APACHE)

#--------------------------------------------------------------------
# Tcl headers, threading, shared/static, compiler flags, symbols
#--------------------------------------------------------------------

TEA_PUBLIC_TCL_HEADERS
TEA_ENABLE_THREADS
TEA_ENABLE_SHARED
TEA_CONFIG_CFLAGS
TEA_ENABLE_SYMBOLS

#--------------------------------------------------------------------
# Use Tcl stubs everywhere except interpool.o (see Makefile.in)
#--------------------------------------------------------------------

USE_TCL_STUBS=1
AC_SUBST(USE_TCL_STUBS)

#--------------------------------------------------------------------
# Library file naming
#--------------------------------------------------------------------

TEA_MAKE_LIB

# websh uses a dynamic $($@_OBJECTS) reference in the link rule;
# override TEA's PKG_OBJECTS-based MAKE_LIB with the classic form.
MAKE_LIB='${SHLIB_LD} -o $@ $($@_OBJECTS) ${SHLIB_LDFLAGS} ${SHLIB_LD_LIBS}'
MAKE_SHARED_LIB='${SHLIB_LD} -o $@ $($@_OBJECTS) ${SHLIB_LDFLAGS} ${SHLIB_LD_LIBS}'
AC_SUBST(MAKE_LIB)
AC_SUBST(MAKE_SHARED_LIB)

# Keep old variable name for Makefile.in
web_LIB_FILE="$PKG_LIB_FILE"
AC_SUBST(web_LIB_FILE)

SHARED_LIB_SUFFIX="${PACKAGE_VERSION}.so"
UNSHARED_LIB_SUFFIX="${PACKAGE_VERSION}.a"
AC_SUBST(SHARED_LIB_SUFFIX)
AC_SUBST(UNSHARED_LIB_SUFFIX)

#--------------------------------------------------------------------
# Variables not exported by the modern tcl.m4 but used in Makefile.in
#--------------------------------------------------------------------

TCL_PACKAGE_PATH="${TCL_BIN_DIR}"
SHLIB_LDFLAGS=""
TCL_DBGX=""
CFLAGS_OPTIMIZE="${TCL_CFLAGS_OPTIMIZE}"
AC_SUBST(TCL_PACKAGE_PATH)
AC_SUBST(SHLIB_LDFLAGS)
AC_SUBST(TCL_DBGX)
AC_SUBST(CFLAGS_OPTIMIZE)

AC_SUBST(TCL_LIB_SPEC)

#--------------------------------------------------------------------
# Tclsh — used for script.h generation and the test target
#--------------------------------------------------------------------

TEA_PROG_TCLSH

#--------------------------------------------------------------------
# Miscellaneous
#--------------------------------------------------------------------

case "`uname -s`" in
    *win32* | *WIN32* | *CYGWIN_NT*)
        CLEANFILES="*.lib *.dll *.exp *.ilk *.pdb vc50.pch" ;;
    *)
        CLEANFILES="*pure* *.cov* ../tests/webtest.log ../tests/*.dat" ;;
esac
AC_SUBST(CLEANFILES)

CYGPATH=echo
case "`uname -s`" in
    *win32* | *WIN32* | *CYGWIN_NT*) CYGPATH="cygpath -w" ;;
esac
AC_SUBST(CYGPATH)

#--------------------------------------------------------------------
# Random number source detection (for randombytes.c)
#--------------------------------------------------------------------

AC_MSG_CHECKING([for sys/random.h])
found_sys_random_h=no
for dir in /usr/include/*-linux-gnu/sys /usr/include/linux; do
    if test -f "$dir/random.h"; then
        AC_DEFINE([HAVE_GETRANDOM],[1],[getrandom syscall available])
        TCL_DEFS="$TCL_DEFS -DHAVE_GETRANDOM=1"
        AC_MSG_RESULT([found in $dir])
        found_sys_random_h=yes
        break
    fi
done
test "$found_sys_random_h" = "no" && AC_MSG_RESULT([not found])

AC_CHECK_FILE([/dev/random],
    [AC_DEFINE([HAVE_DEVICE_RANDOM],[1],[/dev/random present])
     TCL_DEFS="$TCL_DEFS -DHAVE_DEVICE_RANDOM=1"])
AC_CHECK_FILE([/dev/urandom],
    [AC_DEFINE([HAVE_DEVICE_URANDOM],[1],[/dev/urandom present])
     TCL_DEFS="$TCL_DEFS -DHAVE_DEVICE_URANDOM=1"])

AC_SUBST(TCL_DEFS)

#--------------------------------------------------------------------
# Generate output files
#--------------------------------------------------------------------

AC_CONFIG_FILES([Makefile pkgIndex.tcl])
AC_OUTPUT
