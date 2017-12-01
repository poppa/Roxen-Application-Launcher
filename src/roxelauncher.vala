/* -*- Mode: Vala; indent-tabs-mode: s; c-basic-offset: 2; tab-width: 2 -*- */
/* roxenlauncher.vala
 *
 * Copyright (C) Pontus Östlund 2009-2017 <poppanator@gmail.com>
 *
 * This file is part of Roxen Application Launcher (RAL)
 *
 * RAL is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * RAL is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with RAL.  If not, see <http://www.gnu.org/licenses/>.
 */

using Poppa;

namespace Roxenlauncher
{
  public errordomain RoxenError
  {
    /**
     * Generic error
     */
    ANY
  }

  /* Various globals */

  // Main window, doh!
  MainWindow window;

  // Logfile object
  Logger logger;

  // The GSettings object
  Settings conf;

  /* Various constants */

  const string NAME               = _("Roxen™ Application Launcher");
  // The domain of the GSettings schema
  const string DOMAIN             = "com.roxen.Launcher";
  const string DIR                = ".config/roxenlauncher";
  const string FILES_DIR          = "files";
  const string LOGFILE            = DIR + "/ral.log";
  const string MAIN_UI_FILENAME   = "mainwindow.ui";
  const string EDITOR_UI_FILENAME = "application-form.ui";
  const string DATE_FORMAT        = "%Y-%m-%d %H:%M";
  const string LOG_DATE_FORMAT    = "%Y-%m-%d %H:%M:%S";
  const string USER_AGENT         = "Roxen™ Application Launcher for Linux (" +
                                    Config.VERSION + ")";
  const int    WIN_WIDTH          = 650;
  const int    WIN_HEIGHT         = 400;

  /**
   * Struct for storing the main window's width, height, x and y
   */
  struct WindowProps
  {
    int width;
    int height;
    int x;
    int y;
  }

  /**
   * Write a message to the logfile
   *
   * @param m
   */
  void log_message (string m)
  {
    if (App.do_logging)
      logger.log ("[message] %s".printf (m));
  }

  /**
   * Write a warning to the logfile
   *
   * @param m
   */
  void log_warning (string m)
  {
    if (App.do_logging)
      logger.log ("[warning] %s".printf (m));
  }

  /**
   * Write an error to the logfile
   *
   * @param m
   */
  void log_error (string m)
  {
    if (App.do_logging)
      logger.log ("[error] %s".printf (m));
  }

  /**
   * Write a message to stdout if in debug mode
   *
   * @param s
   */
  void wdebug (string s)
  {
    if (App.do_debug) {
      message (s);
    }
  }

  /**
   * Write a warning to stdout if in debug mode
   *
   * @param s
   */
  void warn_debug (string s)
  {
    if (App.do_debug) {
      warning (s);
    }
  }

  /**
   * Initialize application variables
   */
  public void init ()
  {
    conf = new Settings (DOMAIN);
    App.winprops = { conf.get_int ("window-width"),
                     conf.get_int ("window-height"),
                     conf.get_int ("window-left"),
                     conf.get_int ("window-top") };

    foreach (string s in Environment.list_variables ()) {
      if ("KDE" in s) {
        if (App.do_debug)
          message ("Running in KDE (I guess)");

        App.is_kde = true;
        break;
      }
    }

    /*
    if (!Poppa.file_exists (App.logfile)) {
      try {
        var fs = File.new_for_path (App.logfile)
                     .create_readwrite (FileCreateFlags.PRIVATE);
        fs.close ();
      }
      catch (GLib.Error e) {
        warning ("Unable to create log file \"%s\"", App.logfile);
      }
    }
    */

    gc_logs ();

    if (App.do_logging)
      logger = new Logger ();

    setup_editors_and_cts ();
    LauncherFile.load_existing ();

    Notify.init (NAME);
  }

  /**
   * Garbage collect old log files
   */
  void gc_logs () 
  {
    var d = new DateTime.now_local ();
    d = d.add_months (-3);

    TimeVal tv_then;
    d.to_timeval (out tv_then);

    var dir = getdir ("APPLICATION");

    FileEnumerator f;

    try {
      f = File.new_for_path (dir)
              .enumerate_children (FileAttribute.STANDARD_DISPLAY_NAME + "," +
                                   FileAttribute.TIME_MODIFIED,
                                   FileQueryInfoFlags.NONE, null);
    }
    catch (GLib.Error e) {
      warning ("Unable to create FileEnumerator in log file GC");
      return;
    }
    
    FileInfo fi;

    try {
      while ((fi = f.next_file (null)) != null) {
        if (fi.get_file_type () == FileType.REGULAR) {
          var fname = fi.get_display_name ();

          if (fname.has_suffix (".log")) {
            var mod = fi.get_modification_time ();

            if (mod.tv_sec < tv_then.tv_sec) {
              var fp = Path.build_filename (dir, fi.get_display_name ());

              try {
                File.new_for_path (fp).delete (null);
              }
              catch (GLib.Error e) {
                warning ("Unable to remove old log file %s.", 
                         fi.get_display_name ());
              }
            }
          }
        }
      }
    }
    catch (GLib.Error e) {
      warning ("Error enumerating log files: %s", e.message);
    }
  }
   
  /**
   * Set up the exitors and content types
   */
  void setup_editors_and_cts ()
  {
    string[] eds = conf.get_strv ("editors");
    string[] cts = conf.get_strv ("content-types");

    // NOTE: Editors must be loaded before ContentTypes

    foreach (string s in eds) {
      try {
        Editor.add_editor (new Editor.from_string (s));
      }
      catch (RoxenError e) {
        log_warning ("Faild loading editor from string \"%s\": %s"
                     .printf (s, e.message));
      }
    }

    foreach (string s in cts) {
      try {
        ContentType.add_content_type (new ContentType.from_string (s));
      }
      catch (RoxenError e) {
        log_warning ("Faild loading content type from string \"%s\": %s"
                     .printf (s, e.message));
      }
    }
  }

  /**
   * Returns the full path to some predefined and named directories
   *
   * @param which
   */
  public string? getdir (string which)
  {
    switch (which.up ())
    {
      case "$CURRENT": return Environment.get_current_dir ();
      case "$HOME": return Environment.get_home_dir ();
      case "$TMP": return Environment.get_tmp_dir ();
      case "APPLICATION":
        var f = Path.build_filename (getdir ("$home"), DIR);

        if (!FileUtils.test (f, FileTest.EXISTS))
          if (DirUtils.create (f, 0750) == -1)
            error (_("Unable to create local directory \"%s\""), f);

        return f;

      case "FILES":
        var f = Path.build_filename (getdir ("$home"), DIR, FILES_DIR);

        if (!FileUtils.test (f, FileTest.EXISTS))
          if (DirUtils.create_with_parents (f, 0750) == -1)
            error (_("Unable to create local directory \"%s\""), f);

        return f;
    }

    return null;
  }

  /**
   * Constructs the full path to ui element //local_path// depending on if
   * the app is run from the source directory during development, or if it's
   * run installed.
   *
   * @param local_path
   */
  public string? get_ui_path (string local_path)
  {
    // The first and second indices are for local usage during development:
    //   * "data" if executed in the "src" dir.
    //   * "src/data" if executed in the project dir
    //   * "..." executed elsewhere.
    string[] paths = { "data", "../data",
                       Config.DATADIR+"/roxenlauncher/data" };

    string full_path = null;

    foreach (string path in paths) {
      full_path = Path.build_filename (path, local_path);
      if (file_exists (full_path))
        return full_path;
    }

    return null;
  }

  /**
   * Returns a DatTime object with earliest possible date set
   */
  public DateTime get_null_date ()
  {
    return new DateTime (new TimeZone.local (), 1, 1, 1, 0, 0, 0);
  }

  /**
   * Save new window properties
   *
   * @param width
   * @param height
   * @param x
   * @param y
   */
  public void save_window_properties (int width, int height, int x, int y)
  {
    App.winprops.width = width;
    App.winprops.height = height;
    App.winprops.x = x;
    App.winprops.y = y;

    conf.set_int ("window-width",  width);
    conf.set_int ("window-height", height);
    conf.set_int ("window-left",   x);
    conf.set_int ("window-top",    y);
  }


  string get_logfile_name () 
  {
    string prefix = (new DateTime.now_local ()).format ("%Y-%m");
    return "ral-" + prefix + ".log";
  }
   
  /**
   * Static class for runtime variables
   */
  class App
  {
    // Are we running in KDE? Checked in init()
    public static bool is_kde = false;

    // Should we write debug messages? Set on command line
    public static bool do_debug = false;

    /* GSettings */

    public static bool allow_all_certs {
      get { return conf.get_boolean ("allow-any-cert"); }
      set { conf.set_boolean ("allow-any-cert", value); }
    }

    // Should we show notifications or not?
    public static bool do_notifications {
      get { return conf.get_boolean ("notifications"); }
      set { conf.set_boolean ("notifications", value); }
    }

    // Should we minimize to tray
    public static bool do_minimize {
      get { return conf.get_boolean ("minimize-to-tray"); }
      set { conf.set_boolean ("minimize-to-tray", value); }
    }

    public static int  query_timeout {
      get { return conf.get_int ("query-timeout"); }
      set { conf.set_int ("query-timeout", value); }
    }

    // Should we do logging?
    // Like a cache since this can be looked up quite often
    public static bool do_logging {
      get {
        return conf.get_boolean ("enable-logging");
      }
      set {
        conf.set_boolean ("enable-logging", value);

        if (value)
          logger = new Logger ();
      }
    }

    // The logfile path
    static string _logfile = null;
    public static string logfile {
      get {
        if (_logfile == null) {
          _logfile = Path.build_filename (getdir ("APPLICATION"), 
                                          get_logfile_name ());
        }

        return _logfile;
      }
    }

    // Windows width and height, x and y position
    public static WindowProps winprops = { 0, 0, 0, 0 };
  }

  /**
   * Simple logger class
   */
  class Logger : Object
  {
    public string path { get; private set; }
    public File file { get; private set; }

    public Logger ()
    {
      var new_file = !FileUtils.test (App.logfile, FileTest.EXISTS);

      this.path = App.logfile;
      this.file = File.new_for_path (App.logfile);

      if (new_file) {
        log (_("Creating new log file %s").printf (_path));
      }
    }

    public string get_content ()
    {
      try {
        uint8[] content;
        if (file.load_contents (null, out content, null))
          return (string) content;
      }
      catch (GLib.Error e) {
        warning (_("Unable to load log file contents"));
      }

      return "";
    }

    public void log (string message)
    {
      try {
        DateTime now = new DateTime.now_local ();
        string mess = now.format (LOG_DATE_FORMAT) + ": " + message + "\n";

        { var fs = file.append_to (FileCreateFlags.PRIVATE);
          var ds = new DataOutputStream (fs);
          ds.put_string (mess);
        } // streams will close

        Idle.add (() => {
          window.update_logview (mess);
          return false;
        });
      }
      catch (GLib.Error e) {
        GLib.warning (_("Unable to write to logfile %s: %s"), path, e.message);
      }
    }

    public void truncate ()
    {
      try {
        var fs = file.open_readwrite (null);
        fs.truncate_fn (0, null);
        fs.close ();
      }
      catch (GLib.Error e) {
        GLib.warning (_("Unable to truncate log file %s: %s"), path, e.message);
      }
    }
  }

  class Alert : Object
  {
    public static bool confirm (Gtk.Window parent, string message)
    {
      var md = new Gtk.MessageDialog (
        parent,
        Gtk.DialogFlags.DESTROY_WITH_PARENT,
        Gtk.MessageType.QUESTION,
        Gtk.ButtonsType.YES_NO,
        message, ""
      );

      Gtk.ResponseType resp = (Gtk.ResponseType) md.run ();
      md.destroy ();
      return resp == Gtk.ResponseType.YES;
    }
  }
}
