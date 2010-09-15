/* -*- Mode: Vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/*
 * application.vala
 * Copyright (C) Pontus Östlund 2009 <pontus@poppa.se>
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

using Roxenlauncher;

namespace Roxenlauncher
{
  namespace App
  {
    public const string VERSION = Config.VERSION;
    public const string NAME = _("Roxen Application Launcher");
    public const string LIB_UNIQUE_PATH = "com.roxen.launcher";
    public const string DIR = ".config/roxenlauncher";
    public const string FILES_DIR = "files";
    public const string CONFIG = DIR + "/ral.conf";
    public const string MAIN_UI_FILENAME = "mainwindow.ui";
    public const string EDITOR_UI_FILENAME = "application-form.ui";
    public const string GCONF_ROOT = "/apps/roxenlauncher/";
    public const string DATE_FORMAT = "%Y-%m-%d %H:%M";
    public const string USER_AGENT = "Roxen Application Launcher for Linux (" + 
                                     VERSION + ")";
  }
  
  public struct WindowsProperties
  {
    public int width;
    public int height;
    public int x;
    public int y;
  }

  public void init()
  {
    winprops = { 0, 0, 0, 0 };
    try {
			var cfg = get_config();
      winprops.width  = cfg.get_integer("winprops", "width");
      winprops.height = cfg.get_integer("winprops", "height");
      winprops.x      = cfg.get_integer("winprops", "left");;
      winprops.y      = cfg.get_integer("winprops", "top");
    }
    catch {}
  }

  public ConfigFile get_config()
  {
  	string p = getdir("$home") + "/" + App.CONFIG;
		return new ConfigFile(p);
  }
  
  public string? get_ui_path(string local_path)
  {
    // The first index is for local usage during development
    string[] paths = { "gui", "src/gui", Config.DATADIR+"/roxenlauncher/gui" };
    string full_path = null;
    foreach (string path in paths) {
      full_path = Path.build_filename(path, local_path);
      if (file_exists(full_path))
        return full_path;
    }

    return null;
  }

  public void save_window_properties(int width, int height, int x, int y)
  {
    winprops.width = width;
    winprops.height = height;
    winprops.x = x;
    winprops.y = y;
    try {
      var cli = get_config();
      cli.set_integer("winprops", "width",  winprops.width);
      cli.set_integer("winprops", "height", winprops.height);
      cli.set_integer("winprops", "left",   winprops.x);
      cli.set_integer("winprops", "top",    winprops.y);
      cli.save();
    }
    catch (Error e) {
      warning("Failed to save window properties to conf: %s", e.message);
    }
  }
  
  public string get_last_folder()
  {
    string k = null;
    try { k = get_config().get_string("app", "last-folder"); }
    catch {}
    if (k == null) k = getdir("$home"); 
    return k;
  }

  public void set_last_folder(string path)
  {
    var cli = get_config();
    try { 
    	cli.set_string("app", "last-folder", path); 
    	cli.save();
    }
    catch (Error e) {
      warning("Error setting conf key \"last-folder\": %s", e.message);
    }
  }
  
  public bool get_enable_notifications()
  {
    bool v = true;
    try { v = get_config().get_boolean("app", "notifications"); }
    catch {}
    return v;
  }

  public void set_enable_notifications(bool val)
  {
    var cli = get_config();
    try {
    	cli.set_boolean("app", "notifications", val); 
    	cli.save();
    }
    catch (Error e) {
      warning("Error setting GConf value for notifications!");
    }
  }
  
  public bool get_minimize_to_tray()
  {
    bool v = true;
    try { v = get_config().get_boolean("app", "minimize-to-tray"); }
    catch {}

    return v;
  }

  public void set_minimize_to_tray(bool val)
  {
    var cli = get_config();
    try { 
    	cli.set_boolean("app", "minimize-to-tray", val);
    	cli.save();
    }
    catch (Error e) {
      warning("Error setting GConf value for tray minimization!");
    }
  }

  public class Application : Object
  {
    private static GLib.List<Application> applications; 

    /**
     * Returns the list of applications
     */
    public static unowned GLib.List<Application> get_applications()
    {
      return applications;
    }

    /**
     * Add an application
     *
     * @param app
     */
    public static bool add_application(Application app)
    {
      Application a = null;
      if ((a = get_for_mimetype(app.mimetype)) != null)
        return false;

      applications.append(app);
      save_list();
      return true;
    }

    /**
     * Removes the given application from the list
     */
    public static void remove_application(Application app)
    {
      applications.remove(app);
      save_list();
    }

    /**
     * Saves the list of applications to GConf
     */    
    public static void save_list()
    {
      var list = to_gconf_list();
      try {
        var cli = get_config();
        cli.set_string_list("app", "applications", list);
        cli.save();
      }
      catch (Error e) {
        warning("Failed to save applications to GConf: %s", e.message);
      }
    }

    /**
     * Tries to find an application for mimetype
     *
     * @param mimetype
     * @return
     */
    public static Application? get_for_mimetype(string mimetype)
    {
      foreach (Application app in applications)
        if (app.mimetype == mimetype)
          return app;
          
      return null;
    }
    
    /**
     * Creates a list of the applications saveable to GConf
     */
    public static string[] to_gconf_list()
    {
      string[] list = new string[]{};
      
      foreach (Application app in applications)
        list += app.to_gconf_string();
        
      return list;
    }

    /**
     * Load applications from GConf
     */
    public static void load_from_gconf()
    {
      if (applications == null)
        applications = new GLib.List<Application>();
    
      var cli = get_config();
      string[] list = null;
      try { list = cli.get_string_list("app", "applications"); }
      catch {}

      if (list != null) {
        foreach (string s in list) {
          string[] pts = s.split("::");
          var app = new Application(pts[0], pts[1], pts[2]);
          if (pts.length > 3 && pts[3].length > 0)
            app.arguments = pts[3];

          applications.append(app);
        }
      }
    }

    public string name { get; set; }
    public string command { get; set; }
    public string mimetype { get; set; }
    public string arguments { get; set; }
    
    public Application(string name, string command, string mimetype,
                       string arguments="")
    {
      this.name = name;
      this.command = command;
      this.mimetype = mimetype;
      this.arguments = arguments;
    }
    
    public string to_gconf_string()
    {
      return name + "::" + command + "::" + mimetype + "::" + arguments;
    }
  }
}
