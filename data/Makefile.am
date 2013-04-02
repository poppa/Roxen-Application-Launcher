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

mimedir = ${datadir}/mime/packages
mime_DATA = xrl2-mime.xml

EXTRA_DIST =                                                             \
	$(roxenlauncherextra_DATA)                                             \
	$(roxenlauncherpixmaps_DATA)                                           \
	$(gsettings_SCHEMAS)                                                   \
	$(desktop_in_files)                                                    \
	$(mime_DATA)                                                           \
	$(NULL)

install-data-local: install-mimeDATA
	  if which update-mime-database>/dev/null 2>&1; then                   \
	    update-mime-database $(DESTDIR)$(datadir)/mime;                    \
	  fi

uninstall-local:
	  if which update-mime-database>/dev/null 2>&1; then                   \
	    update-mime-database $(DESTDIR)$(datadir)/mime;                    \
	  fi

