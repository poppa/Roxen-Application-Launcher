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

public class Roxenlauncher.Main : Gtk.Application
{
	public static bool is_kde { public get; public set; default = false; }
	public static MainWindow window { public get; private set; }
	public static Tray tray { public get; private set; }
	public static WindowProperties winprops = { 0, 0, 0, 0 };

	static bool opt_version;

  const OptionEntry[] options = {
    { "version", 'v', 0, OptionArg.NONE, ref opt_version, 
      N_("Output version information and exit"), null },
    { null }
  };

	public Main(string app_id, ApplicationFlags flags)
	{
		GLib.Object(application_id: app_id, flags: flags);
	}

	public void on_app_activate()
	{
#if DEBUG
		message("on_app_activate()");
#endif

		if (get_windows() == null) {
			Environment.set_application_name(_("Roxen™ Application Launcher"));
			window = new MainWindow();
			window.set_application(this);
			tray = new Tray();
			tray.hookup();

			init();

			if (window.setup_ui())
				window.show_all();
		}
		/*
		else {
			// Lets not raise the window
		} */
	}
	
	void handle_files(string[] args) 
	{
#if DEBUG
		message("handle_files(%s)", string.joinv(",", args));
#endif

  	if (args.length > 1) {
  		for (int i = 1; i < args.length; i++) {
#if DEBUG
  			message("Incomming file: %s", args[i]);
#endif
  			string d = file_get_contents(args[i]);

  			if (d != null) {
				  LauncherFile lf;

				  try {
				    if (LauncherFile.incomming(d, out lf)) {
				      message("#### Incomming file is new...%s", lf.path);
				    }
				    else {
				      message("#### Incomming file exists locally!");
				      window.set_file_selection(lf);
				    }
				  }
				  catch (GLib.Error e) {
				    warning("Failed to handle incomming file: %s", e.message);
				  }
  			}
  		}
  	}
	}
	
	public int on_command_line(ApplicationCommandLine cl)
	{
		string[] argv = cl.get_arguments();
		
#if DEBUG
		message("on_command_line(%s)", string.joinv(",", argv));
#endif

		if (!get_is_remote()) {
			handle_files(argv);
			return 0;
		}
		
		return 0;
	}
	
  public override bool local_command_line([CCode (array_null_terminated = true, 
                                                  array_length = false)]
                                          ref unowned string[] arguments,
                                          out int exit_status)
  {
#if DEBUG
  	message("Got local commands: %s", string.joinv(", ", arguments));
#endif
  	
  	exit_status = 0;
		bool return_value = true;
  	
  	try { register(); }
  	catch (GLib.Error e) {
  		stderr.printf("Error: %s\n", e.message);
  		exit_status = 1;
  		return true;
  	}

  	unowned string[] local_args = arguments;
  	
  	if (local_args.length <= 1) {
  		activate();
  	}
  	else {
  		try {
				var context = new OptionContext(_(" [FILE]"));
        context.set_help_enabled(true);
        context.add_main_entries(options, null);
        context.add_group(Gtk.get_option_group(true));
        context.parse(ref local_args);
  		}
  		catch (GLib.Error e) {
  			stderr.printf("Error: %s\n", e.message);
  			exit_status = 1;
  			return true;
  		}
  	}
  	
  	if (opt_version) {
  		stdout.printf("%s %s %s\n", Config.PACKAGE, _("Version"), Config.VERSION);
  		exit_status = 0;
  		return true;
  	}

  	if (get_is_remote()) {
  		stdout.printf("Antoher instance of Roxen Application Launcher is " +
  		              "already running\n");
  		return_value = false;
  		exit_status = 1;
  	}
  	else {
	  	activate();
			handle_files(local_args);
	 	}

  	return return_value;
  }

	static int main(string[] args)
	{
#if DEBUG
		message("### DEBUG MODE man ###");
#endif
	
    Intl.setlocale(LocaleCategory.ALL,"");
    Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
    Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain(Config.GETTEXT_PACKAGE);

		Main app = new Main(DOMAIN, ApplicationFlags.FLAGS_NONE);
		app.activate.connect(app.on_app_activate);
		app.command_line.connect(app.on_command_line);

#if DEBUG
		message("app.run()");
#endif

		return app.run(args);
	}
}

namespace Roxenlauncher
{
  public const string VERSION = Config.VERSION;
  public const string NAME = _("Roxen Application Launcher");
  public const string DOMAIN = "com.roxen.launcher";
  public const string DIR = ".config/roxenlauncher";
  public const string FILES_DIR = "files";
  public const string CONFIG = DIR + "/ral.conf";
  public const string MAIN_UI_FILENAME = "mainwindow.ui";
  public const string EDITOR_UI_FILENAME = "application-form.ui";
  public const string DATE_FORMAT = "%Y-%m-%d %H:%M";
  public const string USER_AGENT = "Roxen Application Launcher for Linux (" + 
                                   VERSION + ")";

  public struct WindowProperties
  {
    public int width;
    public int height;
    public int x;
    public int y;
  }
  
  public void init()
  {
    var cfg = get_config();

    Main.winprops.width  = cfg.get_integer("winprops", "width");
    Main.winprops.height = cfg.get_integer("winprops", "height");
    Main.winprops.x      = cfg.get_integer("winprops", "left");;
    Main.winprops.y      = cfg.get_integer("winprops", "top");

		LauncherFile.load_existing();
		Application.load_from_gconf();
		Notify.init(NAME);

    foreach (string s in GLib.Environment.list_variables()) {
      if ("KDE" in s) {
	      Main.is_kde = true; // defined in main.vala
	      break;
      }
    }
  }

  public Poppa.KeyFile get_config()
  {
    string p = getdir("$home") + "/" + CONFIG;
    Poppa.KeyFile c = new Poppa.KeyFile(p);
    c.delimiter = "¤";
    return c;
  }
  
  public string? get_ui_path(string local_path)
  {
    // The first second indices are for local usage during development
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
    Main.winprops.width = width;
    Main.winprops.height = height;
    Main.winprops.x = x;
    Main.winprops.y = y;

    var cli = get_config();
    cli.set_integer("winprops", "width",  Main.winprops.width);
    cli.set_integer("winprops", "height", Main.winprops.height);
    cli.set_integer("winprops", "left",   Main.winprops.x);
    cli.set_integer("winprops", "top",    Main.winprops.y);
    cli.save();
  }
  
  public string get_last_folder()
  {
    string k = get_config().get_string("app", "last-folder");
    if (k == null) k = getdir("$home"); 
    return k;
  }

  public void set_last_folder(string path)
  {
    var cli = get_config();
    cli.set_string("app", "last-folder", path);
    cli.save();
  }
  
  public bool get_enable_notifications()
  {
    bool v = get_config().get_boolean("app", "notifications");
    return v;
  }

  public void set_enable_notifications(bool val)
  {
    var cli = get_config();
    cli.set_boolean("app", "notifications", val);
    cli.save();
  }

  public bool get_minimize_to_tray()
  {
    bool v = get_config().get_boolean("app", "minimize-to-tray");
    return v;
  }

  public void set_minimize_to_tray(bool val)
  {
    var cli = get_config();
    cli.set_boolean("app", "minimize-to-tray", val);
    cli.save();
  }
}

