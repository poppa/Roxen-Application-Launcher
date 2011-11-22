/* -*- Mode: Vala; indent-tabs-mode: s; c-basic-offset: 2; tab-width: 2 -*- */
/* tools.vala
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

class Roxenlauncher.Alert : Object
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

class Roxenlauncher.Logger : Object
{
  public static void warning (string s)
  {
    if (enable_logging)
      logger.log ("[warning] %s".printf (s));
  }
  
  public static void message (string s) 
  {
    if (enable_logging)
      logger.log ("[message] %s".printf (s));
  }

  public string path { get; private set; }
  public File file { get; private set; }

  public Logger (string path)
  {
    this.path = path;
    file = File.new_for_path (path);

    if (!FileUtils.test (path, FileTest.EXISTS)) {
      log (_("Creating log file %s").printf (path));
    }
  }

  public string get_content ()
  {
    try {
      uint8[] content;
      if (file.load_contents (null, out content))
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
      Poppa.DateTime now = Poppa.DateTime.now ();
      string mess = now.to_string () + ": " + message + "\n";

      {
        var fs = file.append_to (FileCreateFlags.PRIVATE);
        var ds = new DataOutputStream (fs);
        ds.put_string (mess);
      } // streams will close

      Idle.add (() => {
        Main.window.update_logview (mess);
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
