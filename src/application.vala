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
using Poppa;

public class Roxenlauncher.Application : Object
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
    message("save_list()\n");
    var list = to_gconf_list();
    message("List length: %d\n", list.length);
    var cli = get_config();
    cli.set_string_list("app", "applications", list);
    cli.save();
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
    
    foreach (Application app in applications) {
      message("App: %s\n", app.to_gconf_string());
      list += app.to_gconf_string();
    }
      
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
    string[] list = cli.get_string_list("app", "applications");

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

