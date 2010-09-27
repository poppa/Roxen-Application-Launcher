/* -*- Mode: Vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/*
 * main.vala
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

// Set in ApplicationLauncher.run()
Roxenlauncher.MainWindow win;
// Set in main()
Roxenlauncher.Tray tray;
// Set in init() in application.vala
Roxenlauncher.WindowsProperties winprops;
// Checked for in init() in application.vala
bool is_kde = false;

public class ApplicationLauncher : Object
{
  private Unique.App instance;

  public static int main (string[] args) 
  {
#if DEBUG
    message("DEBUG MODE: %s\n", Config.DATADIR);
#endif

    Intl.setlocale(LocaleCategory.ALL,"");
    Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
    Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain(Config.GETTEXT_PACKAGE);

    Gtk.init (ref args);
    tray = new Tray();
    return new ApplicationLauncher().run(args);
  }

  public int run(string[] args)
  {
    win = new MainWindow();
    instance = new Unique.App(App.LIB_UNIQUE_PATH, null);

    string[] argslist = new string[args.length-2];
    try { argslist = array_slice(args, 1); }
    catch (Poppa.Error e) {
      warning("Error: %s", e.message);
    }

    if (instance.is_running) {
      if (argslist.length > 0) {
#if DEBUG
        message("Send args: %s", array_implode(argslist, ", "));
#endif
        var md = new Unique.MessageData();
        md.set_text(array_implode(argslist,";"), -1);
        instance.send_message(Unique.Command.OPEN, md);
      }

      Gdk.notify_startup_complete();
      return 0;
    }  

    instance.message_received.connect(on_message_received); 

    init();
    LauncherFile.load_existing();
    Roxenlauncher.Application.load_from_gconf();
	  
    if (argslist.length > 0) {
      foreach (string s in argslist)
        handle_incomming_file(s);
    }

    win.init();
    tray.hookup();
    win.get_window().show_all();
    Gtk.main();

    return 0;
  }
  
  private void handle_incomming_file(string path)
  {
#if DEBUG
    message("*** handle_incomming_file(%s)", path);
#endif

    var d = file_get_contents(path);
    if (d != null) {
      LauncherFile lf;
      try {
        if (LauncherFile.incomming(d, out lf)) {
#if DEBUG
          message("Incomming file is new...%s", lf.path);
#endif
        }
        else {
#if DEBUG
          message("Incomming file exists locally!");
#endif
          win.set_file_selection(lf);
        }
      }
      catch (GLib.Error e) {
        warning("Failed to handle incomming file: %s", e.message);
      }
    }
  }

  private Unique.Response on_message_received(Unique.App instance,
                                              int command,
                                              Unique.MessageData data,
                                              uint time)
  {
    if (command == Unique.Command.OPEN) {
      foreach (string s in data.get_text().split(";"))
        handle_incomming_file(s);
    }

    return Unique.Response.OK;
  }
}
