AC_INIT([roxenlauncher], [1.0.10], [pontus@poppa.se], [roxenlauncher])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS(config.h)
AM_INIT_AUTOMAKE([dist-bzip2])
AM_MAINTAINER_MODE

AC_PROG_CC
AM_PROG_CC_C_O
AC_DISABLE_STATIC
AC_PROG_LIBTOOL

AC_PATH_PROG(VALAC, valac, valac)
AC_SUBST(VALAC)

AH_TEMPLATE([GETTEXT_PACKAGE], [Package name for gettext])
GETTEXT_PACKAGE='roxenlauncher'
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE, "$GETTEXT_PACKAGE")
AC_SUBST(GETTEXT_PACKAGE)
AM_GLIB_GNU_GETTEXT
IT_PROG_INTLTOOL([0.35.0])

AH_TEMPLATE([RL_DEBUG], [Debug flags])
AC_DEFINE(RL_DEBUG, "$RL_DEBUG")
AC_SUBST(RL_DEBUG)

if test "x$localedir" == x
then
	localedir='${datadir}/locale'
	AC_SUBST(localedir)
	AM_GLIB_DEFINE_LOCALEDIR([localedir])
fi

AC_SUBST(CFLAGS)
AC_SUBST(CPPFLAGS)
AC_SUBST(LDFLAGS)

GLIB_REQUIRED=2.22.2
GTK_REQUIRED=2.18.3
UNIQUE_REQUIRED=1.1.2
SOUP24_REQUIRED=2.28.1
GIO_REQUIRED=2.22.2
GDK_REQUIRED=2.18.3
GDK_PIXBUF_REQUIRED=2.18.3
LIBNOTIFY_REQUIRED=0.6

if test "x$RL_WITH_VALA" != x
then
	VALA_REQUIRED=0.12.0
	echo ""
	echo "		### MAINTAINER MODE ###"
	echo ""
	if test "`$VALAC --version`" \< "Vala $VALA_REQUIRED"
	then
		AC_MSG_ERROR([Vala >= $VALA_REQUIRED is required.])
	fi
fi

PKG_CHECK_MODULES(ROXENLAUNCHER,         \
	glib-2.0       >= $GLIB_REQUIRED       \
	gobject-2.0    >= $GLIB_REQUIRED       \
	gtk+-2.0       >= $GTK_REQUIRED        \
	unique-1.0     >= $UNIQUE_REQUIRED     \
	libsoup-2.4    >= $SOUP24_REQUIRED     \
	gio-2.0        >= $GIO_REQUIRED        \
	gdk-2.0        >= $GDK_REQUIRED        \
	libnotify      >= $LIBNOTIFY_REQUIRED  \
	gdk-pixbuf-2.0 >= $GDK_PIXBUF_REQUIRED)

AC_SUBST(ROXENLAUNCHER_CFLAGS)
AC_SUBST(ROXENLAUNCHER_LIBS)

AC_CONFIG_FILES([Makefile
	src/Makefile
	po/Makefile])

AC_OUTPUT
