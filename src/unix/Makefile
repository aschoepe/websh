#
# Makefile.in -- make file def for websh
# nca-073-9
#
# (adapted from sampleextension-0.2)
#
# See the file "license.terms" for information on usage an
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
#
# @(#) $Id: Makefile.in 1170381 2011-09-13 23:04:58Z ronnie $
#

ECHO = echo
TOP_DIR = ..

lib_BINARIES=$(web_LIB_FILE)
BINARIES=$(lib_BINARIES)

SCRIPT_SOURCES = ../generic/context.tcl ../generic/script.ws3 ../generic/cookie.ws3 ../generic/sessctx.ws3 

web_OBJECTS = args.o \
	cfg.o \
	checksum.o \
	command.o \
	conv.o \
	crypt.o \
	nca_d.o \
	dispatch.o \
	filecounter.o \
	filelock.o \
	formdata.o \
	hashutl.o \
	htmlify.o \
	log.o \
	logtocmd.o \
	logtochannel.o \
	logtofile.o \
	logtosyslog.o \
	logutl.o \
	messages.o \
	messagesCmd.o \
	paramlist.o \
	querystring.o \
	request.o \
	script.o \
	uricode.o \
	url.o \
	web.o \
	webout.o \
	weboutint.o \
	webutl.o \
	webutlcmd.o \
	varchannel.o \
	modwebsh_cgi.o \
	request_cgi.o \
	response_cgi.o \
	cJSON.o

web_OBJECTS_ap = apchannel.o \
	interpool.o \
	logtoap.o \
	mod_websh.o \
	modwebsh_ap.o \
	request_ap.o \
	response_ap.o

OBJECTS = $(web_OBJECTS)

web_LIB_FILE = libwebsh3.6.0b5.so
$(web_LIB_FILE)_OBJECTS = $(web_OBJECTS)

# =============================================================================
# This is a list of header files to be installed
# =============================================================================

GENERIC_HDRS=

SHELL = /bin/bash

srcdir = .
prefix = /usr/local
exec_prefix = ${prefix}

bindir = ${exec_prefix}/bin
libdir = ${exec_prefix}/lib
moddir = $(libdir)/httpd/modules
sharedir = $(prefix)/share/websh3.6
docdir = $(sharedir)/htdocs
cfgdir = $(sharedir)/conf

PACKAGE = web
VERSION = 3.6.0b5
CC = cc
CFLAGS_DEBUG = -g
CFLAGS_DEFAULT = -O2
CFLAGS_OPTIMIZE = -O2
CFLAGS_WARNING = -Wall
CLEANFILES = *pure* *.cov* ../tests/webtest.log ../tests/*.dat
EXEEXT = 
LDFLAGS_DEFAULT = 
MAKE_LIB = ${SHLIB_LD} -o $@ $($@_OBJECTS) ${SHLIB_LDFLAGS} ${SHLIB_LD_LIBS}
MAKE_SHARED_LIB = ${SHLIB_LD} -o $@ $($@_OBJECTS) ${SHLIB_LDFLAGS} ${SHLIB_LD_LIBS}
MAKE_STATIC_LIB = ${STLIB_LD} $@ $($@_OBJECTS)
OBJEXT = o
RANLIB = :
SHLIB_CFLAGS = -fPIC
SHLIB_LD = ${CC} ${CFLAGS} ${LDFLAGS} -shared
Platform=$(shell uname -s)
ifeq ($(Platform),Darwin)
SHLIB_LD_CURRENT = $(CC) -bundle -bundle_loader $(HTTPD_BIN) $(LDFLAGS)
LDLIBPATHVAR = DYLD_LIBRARY_PATH
else
SHLIB_LD_CURRENT = $(SHLIB_LD) $(TCL_LD_FLAGS)
LDLIBPATHVAR = LD_LIBRARY_PATH
endif
SHLIB_LDFLAGS = 
SHLIB_LD_LIBS = -L/usr/local/lib -ltclstub8.6
STLIB_LD = ${AR} cr
APRU_LIBS = 
TCL_BIN_DIR = /usr/local/src/tcl8.6.9/unix
TCL_DEFS = -DPACKAGE_NAME=\"tcl\" -DPACKAGE_TARNAME=\"tcl\" -DPACKAGE_VERSION=\"8.6\" -DPACKAGE_STRING=\"tcl\ 8.6\" -DPACKAGE_BUGREPORT=\"\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_SYS_PARAM_H=1 -DUSE_THREAD_ALLOC=1 -D_REENTRANT=1 -D_THREAD_SAFE=1 -DHAVE_PTHREAD_ATTR_SETSTACKSIZE=1 -DHAVE_PTHREAD_ATFORK=1 -DTCL_THREADS=1 -DTCL_CFGVAL_ENCODING=\"iso8859-1\" -DHAVE_ZLIB=1 -DMODULE_SCOPE=extern\ __attribute__\(\(__visibility__\(\"hidden\"\)\)\) -DHAVE_HIDDEN=1 -DHAVE_CAST_TO_UNION=1 -DTCL_SHLIB_EXT=\".so\" -DNDEBUG=1 -DTCL_CFG_OPTIMIZED=1 -DTCL_TOMMATH=1 -DMP_PREC=4 -D_LARGEFILE64_SOURCE=1 -DTCL_WIDE_INT_IS_LONG=1 -DHAVE_GETCWD=1 -DHAVE_MKSTEMP=1 -DHAVE_OPENDIR=1 -DHAVE_STRTOL=1 -DHAVE_WAITPID=1 -DHAVE_GETNAMEINFO=1 -DHAVE_GETADDRINFO=1 -DHAVE_FREEADDRINFO=1 -DHAVE_GAI_STRERROR=1 -DHAVE_STRUCT_ADDRINFO=1 -DHAVE_STRUCT_IN6_ADDR=1 -DHAVE_STRUCT_SOCKADDR_IN6=1 -DHAVE_STRUCT_SOCKADDR_STORAGE=1 -DHAVE_GETPWUID_R_5=1 -DHAVE_GETPWUID_R=1 -DHAVE_GETPWNAM_R_5=1 -DHAVE_GETPWNAM_R=1 -DHAVE_GETGRGID_R_5=1 -DHAVE_GETGRGID_R=1 -DHAVE_GETGRNAM_R_5=1 -DHAVE_GETGRNAM_R=1 -DHAVE_GETHOSTBYNAME_R_6=1 -DHAVE_GETHOSTBYNAME_R=1 -DHAVE_GETHOSTBYADDR_R_8=1 -DHAVE_GETHOSTBYADDR_R=1 -DHAVE_TERMIOS_H=1 -DHAVE_SYS_IOCTL_H=1 -DHAVE_SYS_TIME_H=1 -DTIME_WITH_SYS_TIME=1 -DHAVE_GMTIME_R=1 -DHAVE_LOCALTIME_R=1 -DHAVE_MKTIME=1 -DHAVE_TM_GMTOFF=1 -DHAVE_TIMEZONE_VAR=1 -DHAVE_STRUCT_STAT_ST_BLOCKS=1 -DHAVE_STRUCT_STAT_ST_BLKSIZE=1 -DHAVE_BLKCNT_T=1 -DHAVE_INTPTR_T=1 -DHAVE_UINTPTR_T=1 -DNO_UNION_WAIT=1 -DHAVE_SIGNED_CHAR=1 -DHAVE_LANGINFO=1 -DHAVE_MKSTEMPS=1 -DHAVE_FTS=1 -DHAVE_SYS_IOCTL_H=1 -DTCL_UNLOAD_DLLS=1 -DHAVE_CPUID=1 
TCL_EXTRA_CFLAGS =  -pipe 
TCL_LD_FLAGS =  -Wl,--export-dynamic 
TCL_LIBS = -ldl -lz  -lpthread -lm
TCL_SHLIB_LD_LIBS = ${LIBS}
TCL_SRC_DIR = /usr/local/src/tcl8.6.9
TCL_DBGX = 
TCL_STUB_LIB_FILE = libtclstub8.6.a
TCL_STUB_LIB_SPEC = -L/usr/local/lib -ltclstub8.6
TCL_LIB_SPEC = -L/usr/local/lib -ltcl8.6
TCLSH_PROG = /usr/local/bin/tclsh8.6
TCL_PACKAGE_PATH = /usr/local/lib 

# uncomment the following line if you want to enable the
# Tcl memory and checkmem commands in mod_websh
#MEM_DEBUG_FLAGS = -DTCL_MEM_DEBUG

SHARED_LIB_SUFFIX = 3.6.0b5.so
MODULE_LIB_SUFFIX = $(VERSION).so
UNSHARED_LIB_SUFFIX = 3.6.0b5.a

HTTPD_INCLUDES = -I"/usr/include/apache2" -I"/usr/include/apr-1.0"
# needed for Darwin (OS X) only
HTTPD_BIN = 

AUTOCONF = autoconf

LDFLAGS = $(LDFLAGS_DEFAULT)

INCLUDES = -I"/usr/local/include" $(HTTPD_INCLUDES)

# remove PACKAGE stuff: will cause warnings for Apache >2 and Tcl >=8.5
FIXED_TCL_DEFS = $(filter-out -DPACKAGE_NAME=% -DPACKAGE_TARNAME=% -DPACKAGE_VERSION=% -DPACKAGE_STRING=% -DPACKAGE_BUGREPORT=% 8.% 9.%, $(TCL_DEFS))

EXTRA_CFLAGS = $(FIXED_TCL_DEFS) $(PROTO_FLAGS) $(SECURITY_FLAGS) \
	$(MEM_DEBUG_FLAGS) $(KEYSYM_FLAGS) $(NO_DEPRECATED_FLAGS) \
	$(TCL_EXTRA_CFLAGS)

DEFS = -DVERSION=\"3.6.0b5\" -DSYSV=1 -DUSE_TCL_STUBS=1 $(EXTRA_CFLAGS)

ACLOCAL_M4 = $(srcdir)/aclocal.m4

CPPFLAGS = 
LIBS = 
AR = ar
CFLAGS = ${CFLAGS_DEFAULT} ${CFLAGS_DEBUG} ${CFLAGS_WARNING} ${SHLIB_CFLAGS}
COMPILE = $(CC) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
CCLD = $(CC)
LINK = $(CCLD) $(AM_CFLAGS) $(CFLAGS) $(LDFLAGS) -o $@

# =============================================================================
# main targets (TEA)
# =============================================================================

bin_BINARIES:=websh$(VERSION)

all: binaries libraries

binaries: $(BINARIES) $(OBJECTS) websh

libraries: mod_websh.so

install: all install-binaries install-libraries install-doc

# =============================================================================
# Dist target - to make the tarball.
# =============================================================================

dist: 
	@echo "use ../../makedist to create a tar ball for a specific release"

distdoc: ../../doc/quickref.xml ../../doc/quickref.xsl
	(cd ../../doc/ && make)

# =============================================================================
# Testing
# =============================================================================

test: websh$(VERSION) $(web_LIB_FILE) $(web_OBJECTS)
	@$(LDLIBPATHVAR)="$(strip $(TCL_PACKAGE_PATH)):$(TOP_DIR)/unix:$(LD_LIBRARY_PATH)"; \
	export $(LDLIBPATHVAR); \
	TCL_LIBRARY="$(TCL_SRC_DIR)/library"; export TCL_LIBRARY; \
	WEB_LIBRARY=$(TOP_DIR)/unix/$(web_LIB_FILE); export WEB_LIBRARY; \
	WEB_BIN=$(TOP_DIR)/unix/websh$(VERSION); export WEB_BIN; \
	TCLLIBPATH=$(TCL_PACKAGE_PATH); export TCLLIBPATH; \
	cd $(TOP_DIR)/tests; \
	umask 0; \
	$(TOP_DIR)/unix/websh$(VERSION) webtest.ws3

test.pure: websh$(VERSION).pure $(web_LIB_FILE) $(web_OBJECTS)
	@$(LDLIBPATHVAR)="$(strip $(TCL_PACKAGE_PATH)):$(TOP_DIR)/unix:$(LD_LIBRARY_PATH)"; \
	export $(LDLIBPATHVAR); \
	TCL_LIBRARY="$(TCL_SRC_DIR)/library"; export TCL_LIBRARY; \
	WEB_LIBRARY=$(TOP_DIR)/unix/$(web_LIB_FILE); export WEB_LIBRARY; \
	WEB_BIN=$(TOP_DIR)/unix/websh$(VERSION).pure; export WEB_BIN; \
	TCLLIBPATH=$(TCL_PACKAGE_PATH); export TCLLIBPATH; \
	cd $(TOP_DIR)/tests; \
	umask 0; \
	(echo source webtest.ws3) | ../unix/websh$(VERSION).pure

test.cov: websh$(VERSION).cov $(web_LIB_FILE) $(web_OBJECTS)
	@$(LDLIBPATHVAR)="$(strip $(TCL_PACKAGE_PATH)):$(TOP_DIR)/unix:$(LD_LIBRARY_PATH)"; \
	export $(LDLIBPATHVAR); \
	TCL_LIBRARY="$(TCL_SRC_DIR)/library"; export TCL_LIBRARY; \
	WEB_LIBRARY=$(TOP_DIR)/unix/$(web_LIB_FILE); export WEB_LIBRARY; \
	WEB_BIN=$(TOP_DIR)/unix/websh$(VERSION).cov; export WEB_BIN; \
	TCLLIBPATH=$(TCL_PACKAGE_PATH); export TCLLIBPATH; \
	cd $(TOP_DIR)/tests; \
	umask 0; \
	(echo source webtest.ws3) | ../unix/websh$(VERSION).cov

apachetest: mod_websh.so websh
	@$(LDLIBPATHVAR)="$(strip $(TCL_PACKAGE_PATH)):$(TOP_DIR)/unix:$(LD_LIBRARY_PATH)"; \
	export $(LDLIBPATHVAR); \
	TCL_LIBRARY="$(TCL_SRC_DIR)/library"; export TCL_LIBRARY; \
	WEB_LIBRARY=$(TOP_DIR)/unix/$(web_LIB_FILE); export WEB_LIBRARY; \
	WEB_BIN=$(TOP_DIR)/unix/websh$(VERSION); export WEB_BIN; \
	MOD_WEBSH=$(TOP_DIR)/unix/mod_websh$(MODULE_LIB_SUFFIX); \
	export MOD_WEBSH; \
	HTTPD_BIN=$(HTTPD_BIN); export HTTPD_BIN; \
	TCLLIBPATH=$(TCL_PACKAGE_PATH); export TCLLIBPATH; \
	cd $(TOP_DIR)/apachetests; \
	$(TOP_DIR)/unix/websh$(VERSION) runtests.tcl $(HTTPD_INCLUDES)

depend:

# =============================================================================
# Compile stuff
# =============================================================================

$(web_LIB_FILE): $(web_OBJECTS)
	-rm -f $(web_LIB_FILE)
	${SHLIB_LD} -o $@ $($@_OBJECTS) ${SHLIB_LDFLAGS} ${SHLIB_LD_LIBS}
	$(RANLIB) $(web_LIB_FILE)

script.h: ../generic/tcldecmt.tcl $(SCRIPT_SOURCES)
	$(TCLSH_PROG) ../generic/tcldecmt.tcl $(SCRIPT_SOURCES) > $@

script.o: ../generic/script.c script.h
	$(COMPILE) -I. -c $<

interpool.o: ../generic/interpool.c
	$(COMPILE) -UUSE_TCL_STUBS -c $<

%.o: ../generic/%.c
	$(COMPILE) -c $<

websh: websh$(VERSION) $(web_LIB_FILE)

mod_websh.so: mod_websh$(MODULE_LIB_SUFFIX)


websh$(VERSION): tclAppInit.$(OBJEXT) $(web_LIB_FILE)
	$(CC)  tclAppInit.$(OBJEXT) $(web_LIB_FILE) \
	$(TCL_LIB_SPEC) $(TCL_STUB_LIB_SPEC) $(TCL_LIBS) $(TCL_LD_FLAGS) \
	-o websh$(VERSION)

mod_websh$(MODULE_LIB_SUFFIX): $(web_OBJECTS_ap) $(web_LIB_FILE)
	$(SHLIB_LD_CURRENT) -o mod_websh$(MODULE_LIB_SUFFIX) \
	$(web_OBJECTS_ap) $(web_LIB_FILE) $(APRU_LIBS) \
	$(TCL_LIB_SPEC) $(TCL_STUB_LIB_SPEC)

mod_websh$(UNSHARED_LIB_SUFFIX): $(web_OBJECTS_ap) $(web_OBJECTS)
	$(STLIB_LD) mod_websh$(UNSHARED_LIB_SUFFIX) \
	$(web_OBJECTS_ap) $(web_OBJECTS)

pure: websh$(VERSION).pure

websh$(VERSION).pure: tclAppInit.$(OBJEXT) $(web_LIB_FILE)
	purify $(CC)  tclAppInit.$(OBJEXT) $(web_LIB_FILE) \
	$(TCL_LIB_SPEC) $(TCL_STUB_LIB_SPEC) $(TCL_LIBS) $(TCL_LD_FLAGS) \
	-o websh$(VERSION).pure
	-rm -f *_pure_*.o

cov: websh$(VERSION).cov

websh$(VERSION).cov: tclAppInit.$(OBJEXT) $(web_LIB_FILE)
	purecov $(CC)  tclAppInit.$(OBJEXT) $(web_LIB_FILE) \
	$(TCL_LIB_SPEC) $(TCL_STUB_LIB_SPEC) $(TCL_LIBS) $(TCL_LD_FLAGS) \
	-o websh$(VERSION).cov
	-rm -f *_pure_*.o

.SUFFIXES: .c .o .obj

# =============================================================================
# Cleanup
# =============================================================================

clean:
	-rm -f $(BINARIES)
	-rm -f $(bin_BINARIES)
	-rm -f *.o core *.core
	-rm -f *.$(OBJEXT)
	-rm -f *pure* .*pure*
	-rm -f script.h
	-rm -f *~ ../*~ ../*/*~
	-rm -f ../tests/locktest.*
	-rm -rf ../apachetests/logs ../apachetest/conf/server.conf ../apachetest/conf/websh.conf
	-rm -f $(web_OBJECTS) $(web_OBJECTS_ap) mod_websh$(SHARED_LIB_SUFFIX) mod_websh$(UNSHARED_LIB_SUFFIX)
	-test -z "$(CLEANFILES)" || rm -f $(CLEANFILES)

distclean: clean
	-rm -f *.tab.c
	-rm -f config.cache config.log stamp-h stamp-h[0-9]*
	-rm -f config.status
	-rm -rf autom4te*.cache
	-rm -f configure
	-rm -f Makefile

# =============================================================================
# Install
# =============================================================================

# websh
install-binaries: install-dirs binaries
	cp -f websh$(VERSION) $(bindir)
	rm -f $(bindir)/websh
	ln -s websh$(VERSION) $(bindir)/websh
	if [ -f libwebsh$(SHARED_LIB_SUFFIX) ]; then \
	cp -f libwebsh$(SHARED_LIB_SUFFIX) $(libdir); \
	rm -f $(libdir)/libwebsh.so; \
	ln -s libwebsh$(SHARED_LIB_SUFFIX) $(libdir)/libwebsh.so; \
	fi
	if [ -f libwebsh$(UNSHARED_LIB_SUFFIX) ]; then \
	cp -f libwebsh$(UNSHARED_LIB_SUFFIX) $(libdir); \
	rm -f $(libdir)/libwebsh.a; \
	ln -s libwebsh$(UNSHARED_LIB_SUFFIX) $(libdir)/libwebsh.a; \
	fi
	cp -f $(TOP_DIR)/../src/unix/pkgIndex.tcl $(libdir)

# mod_websh
install-libraries: install-dirs libraries
	cp -f mod_websh$(VERSION).so $(moddir)
	rm -f $(moddir)/mod_websh.so
	ln -s mod_websh$(VERSION).so $(moddir)/mod_websh.so

# documentation / sample mod_websh setup
install-doc: install-dirs
	cp -f $(TOP_DIR)/../doc/mod_websh/conf/*.* $(cfgdir)
	cp -f $(TOP_DIR)/../doc/mod_websh/htdocs/*.* $(docdir)
	cp -f $(TOP_DIR)/../doc/mod_websh/README $(sharedir)

# create destination directories
install-dirs:
	mkdir -p $(bindir)
	mkdir -p $(libdir)
	mkdir -p $(moddir)
	mkdir -p $(sharedir)
	mkdir -p $(docdir)
	mkdir -p $(cfgdir)

# quickref
install-quickref: ../../doc/html/index.html
	mkdir -p $(docdir)/quickref
	cp -f $(TOP_DIR)/../doc/html/*.html $(docdir)/quickref

# create quickref html documentation
../../doc/html/index.html: $(TOP_DIR)/../doc/quickref.xml $(TOP_DIR)/../doc/quickref.xsl
	cd $(TOP_DIR)/../doc/; make

# =============================================================================
# Makefile and configure rules
# =============================================================================

Makefile: $(srcdir)/Makefile.in  $(srcdir)/config.status
	cd $(srcdir) \
	  && CONFIG_FILES=$@ CONFIG_HEADERS= $(SHELL) ./config.status

config.status: $(srcdir)/configure $(CONFIG_STATUS_DEPENDENCIES)
	$(SHELL) ./config.status --recheck

$(srcdir)/configure: $(srcdir)/configure.in $(ACLOCAL_M4) $(CONFIGURE_DEPENDENCIES)
	cd $(srcdir) && $(AUTOCONF)

.PHONY: all binaries libraries clean distclean depend install test

# Tell versions [3.59,3.63) of GNU make to not export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:
