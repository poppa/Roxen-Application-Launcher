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

using Gee;
using Roxenlauncher;

namespace Roxenlauncher
{
  namespace App
  {
    public const string VERSION = Config.VERSION;
    public const string NAME = _("Roxen Application Launcher");
    public const string LIB_UNIQUE_PATH = "com.roxen.launcher";
    public const string DIR = ".roxenlauncher";
    public const string FILES_DIR = "files";
    public const string MAIN_UI_FILENAME = "mainwindow.ui";
    public const string EDITOR_UI_FILENAME = "application-form.ui";
    public const string GCONF_ROOT = "/apps/roxenlauncher/";
    public const string DATE_FORMAT = "%Y-%m-%d %H:%M";
    public const string USER_AGENT = "Roxen Application Launcher for Linux (" + 
                                     VERSION + ")";
    //public const string LAST_FOLDER = "~/";
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
    var cli = GConf.Client.get_default();
    try {
      string p        = App.GCONF_ROOT + "properties/";
      winprops.width  = cli.get_int(p  + "window-width");
      winprops.height = cli.get_int(p  + "window-height");
      winprops.x      = cli.get_int(p  + "window-x");
      winprops.y      = cli.get_int(p  + "window-y");
    }
    catch (Error e) {
      warning("Failed to read window properties from GConf: %s", e.message);
    }
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
      var cli = GConf.Client.get_default();
      string p = App.GCONF_ROOT + "properties/";
      cli.set_int(p + "window-width",  winprops.width);
      cli.set_int(p + "window-height", winprops.height);
      cli.set_int(p + "window-x",      winprops.x);
      cli.set_int(p + "window-y",      winprops.y);
    }
    catch (Error e) {
      warning("Failed to save window properties to GConf: %s", e.message);
    }
  }
  
  public string get_last_folder()
  {
    var cli = GConf.Client.get_default();
    string k = null;
    try { k = cli.get_string(App.GCONF_ROOT + "properties/last-folder"); }
    catch (Error e) {
      warning("Error getting GConf key \"%s\": %s", k, e.message);
    }
    
    if (k == null) k = getdir("$home"); 
    return k;
  }

  public void set_last_folder(string path)
  {
    var cli = GConf.Client.get_default();
    var key = App.GCONF_ROOT + "properties/last-folder";
    try { cli.set_string(key, path); }
    catch (Error e) {
      warning("Error setting GConf key \"%s\": %s", key, e.message);
    }
  }
  
  public bool get_enable_notifications()
  {
    var cli = GConf.Client.get_default();
    bool v = true;
    try { v = cli.get_bool(App.GCONF_ROOT + "properties/notifications"); }
    catch (Error e) {
      warning("Error getting GConf value for notifications!");
    }
    
    return v;
  }

  public void set_enable_notifications(bool val)
  {
    var cli = GConf.Client.get_default();
    try { cli.set_bool(App.GCONF_ROOT + "properties/notifications", val); }
    catch (Error e) {
      warning("Error setting GConf value for notifications!");
    }
  }
  
  public void set_minimize_to_tray(bool val)
  {
    var cli = GConf.Client.get_default();
    try { cli.set_bool(App.GCONF_ROOT + "properties/minimize-to-tray", val); }
    catch (Error e) {
      warning("Error setting GConf value for tray minimization!");
    }
  }
  
  public bool get_minimize_to_tray()
  {
    var cli = GConf.Client.get_default();
    bool v = true;
    try { v = cli.get_bool(App.GCONF_ROOT + "properties/minimize-to-tray"); }
    catch (Error e) {
      warning("Error getting GConf value for minimization!");
    }

    return v;
  }

  public class Application : Object
  {
    private static ArrayList<Application> applications; 

    /**
     * Returns the list of applications
     */
    public static ArrayList<Application> get_applications()
    {
      return applications;
    }

    /**
     * Add an application
     *
     * @param app
     */
    public static void add_application(Application app)
    {
      if (applications == null)
        applications = new ArrayList<Application>();
    
      Application a = null;
      if ((a = get_for_mimetype(app.mimetype)) != null)
        return;

#if DEBUG
      message("Do add application...");
#endif

      applications.add(app);
      save_list();
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
        var cli = GConf.Client.get_default();
        var key = App.GCONF_ROOT + "settings/applications";
        cli.set_list(key, GConf.ValueType.STRING, list);
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
      if (applications == null)
        applications = new ArrayList<Application>();
    
      if (applications.size == 0)
        return null;
    
      foreach (Application app in applications)
        if (app.mimetype == mimetype)
          return app;
          
      return null;
    }
    
    /**
     * Creates a list of the applications saveable to GConf
     */
    public static SList<string> to_gconf_list()
    {
      if (applications == null)
        applications = new ArrayList<Application>();
        
      SList<string> list = new SList<string>();
      
      foreach (Application app in applications)
        list.append(app.to_gconf_string());
        
      return list;
    }

    /**
     * Load applications from GConf
     */
    public static void load_from_gconf()
    {
      if (applications == null)
        applications = new ArrayList<Application>();
    
      var cli = GConf.Client.get_default();
      var key = App.GCONF_ROOT + "settings/applications";
      SList<string> list = null;
      try { list = cli.get_list(key, GConf.ValueType.STRING); }
      catch (Error e) {
        warning("Error getting GConf list for \"%s\": %s", key, e.message);
      }

      if (list != null) {
        foreach (string s in list) {
          string[] pts = s.split("::");
          var app = new Application(pts[0], pts[1], pts[2]);
          if (pts.length > 3 && pts[3].length > 0)
            app.arguments = pts[3];

          applications.add(app);
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