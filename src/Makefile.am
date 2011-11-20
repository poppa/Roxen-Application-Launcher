SUBDIRS = data

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
	launcherfile.vala                                                      \
	tools.vala                                                             \
	tray.vala                                                              \
	mainwindow.vala                                                        \
	poppa.vala                                                             \
	editor.vala                                                            \
	content-type.vala                                                      \
	roxelauncher.vala                                                      \
	content-type-form.vala                                                 \
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
	$(NULL)

roxenlauncher_LDADD =                                                    \
	$(ROXENLAUNCHER_LIBS)                                                  \
	$(NULL)


DISTCLEANFILES =                                                         \
	$(NULL)

