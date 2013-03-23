#SUBDIRS = pixmap

NULL= 

gsettings_SCHEMAS = com.roxen.Launcher.gschema.xml

@GSETTINGS_RULES@

roxenlauncherextradir = ${datadir}/roxenlauncher/data
roxenlauncherextra_DATA =                                                \
	mainwindow.ui                                                          \
	content-type.ui                                                        \
	$(NULL)

roxenlauncherpixmapsdir = ${datadir}/roxenlauncher/data/pixmap
roxenlauncherpixmaps_DATA =                                              \
	pixmap/roxen-logo.png                                                  \
	pixmap/roxen-logo-small.png                                            \
	pixmap/roxen-logo.svg                                                  \
	$(NULL)

desktopdir=$(datadir)/applications
desktop_in_files=roxen-launcher.desktop.in
desktop_DATA=roxen-launcher.desktop
@INTLTOOL_DESKTOP_RULE@


EXTRA_DIST =                                                             \
	$(roxenlauncherextra_DATA)                                             \
	$(roxenlauncherpixmaps_DATA)                                           \
	$(gsettings_SCHEMAS)                                                   \
	$(desktop_in_files)                                                    \
	$(NULL)

