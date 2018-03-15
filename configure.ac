AC_PREREQ([2.64])
AC_INIT(roxenlauncher,
        2.0.13,
        [poppanator@gmail.com],
        [roxenlauncher],
        [https://github.com/poppa/Roxen-Application-Launcher])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_SRCDIR([configure.ac])
AC_CONFIG_MACRO_DIR([m4])
AC_CHECK_LIB(gthread-2.0, g_thread_init)

AM_INIT_AUTOMAKE([1.1 -Wall])
AM_MAINTAINER_MODE([enable])

AC_PROG_CC
AM_PROG_CC_STDC
AC_HEADER_STDC
AM_PROG_VALAC([0.16])

# Initialize libtool
LT_PREREQ([2.2])
LT_INIT

CFLAGS="${CFLAGS} -Wall -lm"
CFLAGS+=" -DGSEAL_ENABLE"

GNOME_MAINTAINER_MODE_DEFINES
GNOME_COMPILE_WARNINGS([maximum])

#*******************************************************************************
#
# Internationalization
#
#*******************************************************************************
AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.17])

GETTEXT_PACKAGE=roxenlauncher
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE", [GETTEXT package name])
IT_PROG_INTLTOOL([0.40.0])

AC_SUBST(CFLAGS)
AC_SUBST(CPPFLAGS)
AC_SUBST(LDFLAGS)

#*******************************************************************************
#
# Check libraries
#
#*******************************************************************************

GLIB_REQUIRED=2.30.0
GTK_REQUIRED=3.6
SOUP24_REQUIRED=2.36.0
GIO_REQUIRED=2.3.0
GDK_PIXBUF_REQUIRED=2.24.0
LIBNOTIFY_REQUIRED=0.7.4

PKG_CHECK_MODULES(ROXENLAUNCHER,         \
	glib-2.0       >= $GLIB_REQUIRED       \
	gobject-2.0    >= $GLIB_REQUIRED       \
	gtk+-3.0       >= $GTK_REQUIRED        \
	libsoup-2.4    >= $SOUP24_REQUIRED     \
	gio-2.0        >= $GIO_REQUIRED        \
	libnotify      >= $LIBNOTIFY_REQUIRED  \
	gdk-pixbuf-2.0 >= $GDK_PIXBUF_REQUIRED)

AC_SUBST(ROXENLAUNCHER_CFLAGS)
AC_SUBST(ROXENLAUNCHER_LIBS)

GLIB_GSETTINGS

AC_CONFIG_FILES([
	Makefile
	src/Makefile
	data/Makefile
	po/Makefile
])

AC_OUTPUT

