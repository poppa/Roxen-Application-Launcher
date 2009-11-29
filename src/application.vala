using Gee;
using Roxenlauncher;

namespace Roxenlauncher
{
  namespace App
  {
    public const string NAME = "Roxen Application Launcher";
    public const string LIB_UNIQUE_PATH = "com.roxen.launcher";
    public const string DIR = ".roxenlauncher";
    public const string FILES_DIR = "files";
    public const string MAIN_UI_FILENAME = "mainwindow.ui";
    public const string EDITOR_UI_FILENAME = "application-form.ui";
    public const string UI_PATH = "gui:"+Config.DATADIR+"/roxenlauncher/ui";
    public const string GCONF_ROOT = "/apps/roxenlauncher/";
    
    public const string LAST_FOLDER = "~/";
  }
  
  public string get_last_folder()
  {
    var cli = GConf.Client.get_default();
    string k = null;
    try {
      k = cli.get_string(App.GCONF_ROOT + "properties/last-folder");
    }
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
    try {
      cli.set_string(key, path);
      message("Set last folder to: %s", path);
    }
    catch (Error e) {
      warning("Error setting GConf key \"%s\": %s", key, e.message);
    }
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

      message("Do add application...");

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
      unowned SList<string> list = null;
      try {
        list = cli.get_list(key, GConf.ValueType.STRING);
      }
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