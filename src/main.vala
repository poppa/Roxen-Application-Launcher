/* -*- Mode: Vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* main.vala
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

public class Roxenlauncher.Main : Gtk.Application
{
	public static bool is_kde       { public get; public set; default = false; }
	public static bool do_debug     { public get; public set; default = false; }
	public static MainWindow window { public get; private set; }
	public static Tray tray         { public get; private set; }
	public static WindowProperties winprops = { 0, 0, 0, 0 };

	static bool opt_version;
	static bool opt_debug;

  const OptionEntry[] options = {
    { "version", 'v', 0, OptionArg.NONE, ref opt_version, 
      N_("Output version information and exit"), null },
		{ "debug", 'd', 0, OptionArg.NONE, ref opt_debug,
			N_("Debug mode. Will print HTTP trafic on download and upload " +
			   "and other various info to stdout") },
    { null }
  };

	public Main (string app_id, ApplicationFlags flags)
	{
		GLib.Object (application_id: app_id, flags: flags);
	}

	public void on_app_activate ()
	{
		if (get_windows () == null) {
			Environment.set_application_name (_("Roxen™ Application Launcher"));

			window = new MainWindow ();
			window.set_application (this);

			tray = new Tray ();
			tray.hookup ();
			
			init ();

			if (window.setup_ui ()) {
				window.show_all ();
				Logger.message (_("Application launcher started"));

				string oldconf = Path.build_filename (getdir("$home"), DIR, "ral.conf");

				if (file_exists (oldconf)) {
					try { File.new_for_path (oldconf).delete (); }
					catch (GLib.Error e) {
						Logger.message ("Error removing old config file: %s"
						                .printf (e.message));
					}
				}
			}
		}
	}
	
	void handle_files (string[] args) 
	{
		if (Main.do_debug && args.length > 1)
			message ("handle_files(%s)", string.joinv (",", args));

  	if (args.length > 1) {
  		for (int i = 1; i < args.length; i++) {
  			string d = file_get_contents (args[i]);

  			if (d != null) {
				  LauncherFile lf;

				  try {
				    if (LauncherFile.incomming (d, out lf)) {
							if (Main.do_debug)
				    		message ("Incomming file is new...%s", lf.path);
				    }
				    else {
							if (Main.do_debug)
				    		message ("Incomming file exists locally!");

				      window.set_file_selection (lf);
				    }
				  }
				  catch (GLib.Error e) {
						Logger.warning (_("Failed to handle incomming file: %s")
						                .printf (e.message));
				  }
  			}
  		}
  	}
	}

	public int on_command_line (ApplicationCommandLine cl)
	{
		string[] argv = cl.get_arguments ();
		
		if (Main.do_debug)
			message ("on_command_line(%s)", string.joinv (",", argv));

		if (!get_is_remote ()) {
			handle_files (argv);
			return 0;
		}
		
		return 0;
	}
	
  public override bool local_command_line ([CCode (array_null_terminated = true, 
                                                   array_length = false)]
                                           ref unowned string[] arguments,
                                           out int exit_status)
  {
  	exit_status = 0;
		bool return_value = true;
  	
  	try { register (); }
  	catch (GLib.Error e) {
  		stderr.printf ("Error: %s\n", e.message);
  		exit_status = 1;
  		return true;
  	}

  	unowned string[] local_args = arguments;
  	
  	if (local_args.length <= 1) {
  		activate ();
  	}
  	else {
  		try {
				var context = new OptionContext (_(" [FILE]"));
        context.set_help_enabled (true);
        context.add_main_entries (options, null);
        context.add_group (Gtk.get_option_group (true));
        context.parse (ref local_args);
  		}
  		catch (GLib.Error e) {
  			stderr.printf ("Error: %s\n", e.message);
  			exit_status = 1;
  			return true;
  		}
  	}
  	
  	if (opt_version) {
  		stdout.printf ("%s %s %s\n", Config.PACKAGE, _("Version"), 
		                 Config.VERSION);
  		exit_status = 0;
  		return true;
  	}

		do_debug = opt_debug;

  	if (get_is_remote ()) {
  		stdout.printf (_("Antoher instance of Roxen Application Launcher is " +
  		                 "already running") + "\n");
  		return_value = false;
  		exit_status = 1;
  	}
  	else {
	  	activate ();
			handle_files (local_args);
	 	}

  	return return_value;
  }

	static int main (string[] args)
	{
    Intl.setlocale (LocaleCategory.ALL,"");
    Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
    Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain (Config.GETTEXT_PACKAGE);

		Main app = new Main (DOMAIN, ApplicationFlags.FLAGS_NONE);
		app.activate.connect (app.on_app_activate);
		app.command_line.connect (app.on_command_line);

		return app.run (args);
	}
}
