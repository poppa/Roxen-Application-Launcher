is_maintainer=false
for opt in $*; do
case $opt in
	--enable-maintainer-mode)
		is_maintainer=true
		;;
esac
done

AC_INIT([roxenlauncher], [0.4.0], [pontus@poppa.se], [roxenlauncher])
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

#AM_CONDITIONAL([WITHOUT_VALA], [test x$RL_VALA = x])

AH_TEMPLATE([GETTEXT_PACKAGE], [Package name for gettext])
GETTEXT_PACKAGE='roxenlauncher'
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE, "$GETTEXT_PACKAGE")
AC_SUBST(GETTEXT_PACKAGE)
AM_GLIB_GNU_GETTEXT
IT_PROG_INTLTOOL([0.35.0])

if test "x$localedir" == x
then
	localedir='${datadir}/locale'
	AC_SUBST(localedir)
	AM_GLIB_DEFINE_LOCALEDIR([localedir])
fi

AC_SUBST(CFLAGS)
AC_SUBST(CPPFLAGS)
AC_SUBST(LDFLAGS)

GLIB_REQUIRED=2.12.0
GTK_REQUIRED=2.10.0
GEE_REQUIRED=0.5
UNIQUE_REQUIRED=1.0
SOUP24_REQUIRED=2.4.0
GCONF_REQUIRED=2.0
GIO_REQUIRED=2.0
GDK_REQUIRED=2.0
GNOME_REQUIRED=2.26.0
GDK_PIXBUF_REQUIRED=2.0

if test "x$RL_WITH_VALA" != x
then
	VALA_REQUIRED=0.7.7
	echo ""
	echo "		### MAINTAINER MODE ###"
	echo ""
	if test "`$VALAC --version`" \< "Vala $VALA_REQUIRED"
	then
		AC_MSG_ERROR([Vala >= $VALA_REQUIRED is required.])
	fi
fi

PKG_CHECK_MODULES(ROXENLAUNCHER,    \
	glib-2.0 >= $GLIB_REQUIRED        \
	gobject-2.0 >= $GLIB_REQUIRED     \
	gtk+-2.0 >= $GTK_REQUIRED         \
	gee-1.0 >= $GEE_REQUIRED          \
	unique-1.0 >= $UNIQUE_REQUIRED    \
	libsoup-2.4 >= $SOUP24_REQUIRED   \
	gconf-2.0 >= $GCONF_REQUIRED      \
	gio-2.0 >= $GIO_REQUIRED          \
	gdk-2.0 >= $GDK_REQUIRED          \
	libgnome-2.0 >= $GNOME_REQUIRED   \
	gdk-pixbuf-2.0 >= $GDK_PIXBUF_REQUIRED)

AC_SUBST(ROXENLAUNCHER_CFLAGS)
AC_SUBST(ROXENLAUNCHER_LIBS)

AC_CONFIG_FILES([Makefile
	src/Makefile
	po/Makefile])

AC_OUTPUT
