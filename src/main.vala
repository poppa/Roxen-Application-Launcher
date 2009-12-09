
using GLib;
using Roxenlauncher;

Roxenlauncher.MainWindow win;
Roxenlauncher.Tray tray;

static int main (string[] args) 
{
  Gtk.init (ref args);
  tray = new Tray();
	return new ApplicationLauncher().run(args);
}

public class ApplicationLauncher : Object
{
  private Unique.App instance;

  public int run(string[] args)
  {
    message("User agent: %s", App.USER_AGENT);
    win = new MainWindow();
    instance = new Unique.App(App.LIB_UNIQUE_PATH, null);

    string[] argslist = new string[args.length-2];
    try { argslist = slice(args, 1); }
    catch (Error e) {
      warning("Error: %s", e.message);
    }

    if (instance.is_running) {
      if (argslist.length > 0) {
        message("Send args: %s", implode(argslist, ", "));
        var md = new Unique.MessageData();
        md.set_text(implode(argslist,";"), -1);
        instance.send_message(Unique.Command.OPEN, md);
      }

      Gdk.notify_startup_complete();
      return 0;
    }  

    instance.message_received += on_message_received; 

	  LauncherFile.load_existing();
	  Application.load_from_gconf();
	  
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
    message("*** handle_incomming_file(%s)", path);
    var d = file_get_contents(path);
    if (d != null) {
      LauncherFile lf;
      try {
        if (LauncherFile.incomming(d, out lf)) {
          message("Incomming file is new...%s", lf.path);
        }
        else {
          message("Incomming file exists locally!");
        } 
      }
      catch (Error e) {
        message("Failed to handle incomming file: %s", e.message);
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