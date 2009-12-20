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
	http-client.vala                                                       \
	launcherfile.vala                                                      \
	tools.vala                                                             \
	tray.vala                                                              \
	mainwindow.vala                                                        \
	application-form.vala                                                  \
	$(NULL)

roxenlauncher_VALAFLAGS =                                                \
	--thread                                                               \
	--pkg=gtk+-2.0                                                         \
	--pkg=gee-1.0                                                          \
	--pkg=gdk-2.0                                                          \
	--pkg=gconf-2.0                                                        \
	--pkg=unique-1.0                                                       \
	--pkg=libsoup-2.4                                                      \
	--pkg=gio-2.0                                                          \
	--pkg=gee-1.0                                                          \
	--pkg=libgnome-2.0                                                     \
	--pkg=gdk-pixbuf-2.0                                                   \
	--vapidir=.                                                            \
	--pkg=config                                                           \
	$(RL_DEBUG)                                                            \
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
	$(NULL)

EXTRA_DIST =                                                             \
	$(roxenlauncherextra_DATA)                                             \
	$(roxenlauncherpixmaps_DATA)                                           \
	$(NULL)

DISTCLEANFILES =                                                         \
	$(NULL)

