/* -*- Mode: Vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* roxenlauncher.vala
 * 
 * Copyright (C) Pontus Östlund 2009-2011 <pontus@poppa.se>
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
    BAD_LAUNCHERFILE,
    ANY
  }

	Logger logger;
	Settings conf;

  const string NAME               = _("Roxen Application Launcher");
	// The domain of the GSettings schema
  const string DOMAIN             = "com.roxen.Launcher";
  const string DIR                = ".config/roxenlauncher";
  const string FILES_DIR          = "files";
  const string CONFIG             = DIR + "/ral.conf";
  const string MAIN_UI_FILENAME   = "mainwindow.ui";
  const string EDITOR_UI_FILENAME = "application-form.ui";
  const string DATE_FORMAT        = "%Y-%m-%d %H:%M";
  const string USER_AGENT         = "Roxen Application Launcher for Linux (" + 
                                    Config.VERSION + ")";

  public struct WindowProperties
  {
    public int width;
    public int height;
    public int x;
    public int y;
  }
  
  public void init ()
  {
		conf = new Settings (DOMAIN);

    Main.winprops.width  = conf.get_int ("window-width");
    Main.winprops.height = conf.get_int ("window-height");
    Main.winprops.x      = conf.get_int ("window-left");
    Main.winprops.y      = conf.get_int ("window-top");

    foreach (string s in Environment.list_variables ()) {
      if ("KDE" in s) {
	      Main.is_kde = true; // defined in main.vala
	      break;
      }
    }

		string lf = get_log_file ();
		if (!Poppa.file_exists (lf)) {
			try {
				var fs = File.new_for_path (lf)
					           .create_readwrite (FileCreateFlags.PRIVATE);
				fs.close ();
			}
			catch (GLib.Error e) {
				warning ("Unable to create log file");
			}
		}

		if (get_enable_logging ()) 
			logger = new Logger (lf);

		setup_editors_and_cts ();

		LauncherFile.load_existing ();
		Notify.init (NAME);
  }

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
				Logger.warning ("Faild loading editor from string \"%s\": %s"
				                .printf(s, e.message));          
			}
		}

		foreach (string s in cts) {
			try {
				ContentType.add_content_type (new ContentType.from_string (s));
			}
			catch (RoxenError e) {
				Logger.warning ("Faild loading content type from string \"%s\": %s"
				                .printf(s, e.message));          
			}
		}
	}

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
            error (_("Unable to create local directory")); 

        return f;

      case "FILES":
        var f = Path.build_filename (getdir ("$home"), DIR, FILES_DIR);

        if (!FileUtils.test (f, FileTest.EXISTS)) 
          if (DirUtils.create_with_parents (f, 0750) == -1)
            error (_("Unable to create local directory"));

        return f;
    }

    return null;
  }

  public string? get_ui_path (string local_path)
  {
    // The first second indices are for local usage during development
		// "data" if executed in the "src" dir.
		// "src/data" if executed in the project dir
		// "..." executed elsewhere.
    string[] paths = { "data", "src/data", 
			                 Config.DATADIR+"/roxenlauncher/data" };
    string full_path = null;

    foreach (string path in paths) {
      full_path = Path.build_filename (path, local_path);
      if (file_exists (full_path))
        return full_path;
    }

    return null;
  }

  public void save_window_properties (int width, int height, int x, int y)
  {
    Main.winprops.width = width;
    Main.winprops.height = height;
    Main.winprops.x = x;
    Main.winprops.y = y;

    conf.set_int ("window-width",  Main.winprops.width);
    conf.set_int ("window-height", Main.winprops.height);
    conf.set_int ("window-left",   Main.winprops.x);
    conf.set_int ("window-top",    Main.winprops.y);
  }
  
  public bool get_enable_notifications ()
  {
    return conf.get_boolean ("notifications");
  }

  public void set_enable_notifications (bool val)
  {
    conf.set_boolean ("notifications", val);
  }

  public bool get_minimize_to_tray ()
  {
    return conf.get_boolean ("minimize-to-tray");
  }

  public void set_minimize_to_tray (bool val)
  {
    conf.set_boolean ("minimize-to-tray", val);
  }

	private bool enable_logging = false;
	private bool init_enable_logging = false;
  public bool get_enable_logging ()
  {
		if (init_enable_logging)
			return enable_logging;

		init_enable_logging = true;
    enable_logging = conf.get_boolean ("enable-logging");
    return enable_logging;
  }

  public void set_enable_logging (bool val)
  {
    conf.set_boolean ("enable-logging", val);

		enable_logging = val;
		
		if (val) {
			logger = new Logger (get_log_file ());
			Main.window.load_logfile ();
		}
		else {
			if (logger != null)
				logger = null;
		}
  }

	public string get_log_file ()
	{
		string logfile = conf.get_string ("logfile");

		if (logfile.length == 0)
			logfile = Path.build_filename (getdir ("APPLICATION"), "ral.log");

		return logfile;
	}

	public void set_log_file (string path)
	{
		conf.set_string ("logfile", path);

		if (get_enable_logging ()) {
			logger = new Logger (path);
			Main.window.load_logfile ();
		}
	}
}
