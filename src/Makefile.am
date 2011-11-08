NULL = 

AM_CPPFLAGS =                                                            \
	-DDATADIR=\""$(datadir)"\"                                             \
	-DGETTEXT_PACKAGE=\""$(GETTEXT_PACKAGE)"\"                             \
	-DLOCALEDIR=\""$(localedir)"\"                                         \
	$(ROXENLAUNCHER_CFLAGS)                                                \
	-include $(CONFIG_HEADER)                                              \
	$(NULL)

BUILT_SOURCES = roxenlauncher_vala.stamp
bin_PROGRAMS = roxenlauncher

roxenlauncher_SOURCES =                                                  \
	main.vala                                                              \
	application.vala                                                       \
	launcherfile.vala                                                      \
	tools.vala                                                             \
	tray.vala                                                              \
	mainwindow.vala                                                        \
	application-form.vala                                                  \
	keyfile.vala                                                           \
	poppa.vala                                                             \
	soppa.c                                                                \
	$(NULL)

roxenlauncher_VALAFLAGS =                                                \
	--thread                                                               \
	--pkg=gmodule-2.0                                                      \
	--pkg=gtk+-3.0                                                         \
	--pkg=libsoup-2.4                                                      \
	--pkg=gio-2.0                                                          \
	--pkg=gdk-pixbuf-2.0                                                   \
	--pkg=libnotify                                                        \
	--vapidir=.                                                            \
	--pkg=config                                                           \
	--pkg=soppa                                                            \
	$(NULL)

roxenlauncher_LDADD =                                                    \
	$(ROXENLAUNCHER_LIBS)                                                  \
	$(NULL)

roxenlauncherextradir = ${datadir}/roxenlauncher/gui
roxenlauncherextra_DATA =                                                \
	gui/mainwindow.ui                                                      \
	gui/application-form.ui                                                \
	$(NULL)

roxenlauncherpixmapsdir = ${datadir}/roxenlauncher/gui/pixmap
roxenlauncherpixmaps_DATA =                                              \
	gui/pixmap/roxen-logo.png                                              \
	gui/pixmap/roxen-logo-small.png                                        \
	gui/pixmap/roxen-logo.svg                                              \
	gui/pixmap/down_48.png                                                 \
	gui/pixmap/up_48.png                                                   \
	gui/pixmap/warning_48.png                                              \
	$(NULL)

EXTRA_DIST =                                                             \
	$(roxenlauncherextra_DATA)                                             \
	$(roxenlauncherpixmaps_DATA)                                           \
	soppa.h \
	$(NULL)

DISTCLEANFILES =                                                         \
	$(NULL)

