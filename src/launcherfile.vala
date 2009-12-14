using Gee;
using Roxenlauncher;

public class LauncherFile : Object
{
  private static ArrayList<LauncherFile> launcherfiles =
    new ArrayList<LauncherFile>();

  /**
   * Returns the list of launcher files
   * 
   * @return
   */
  public static ArrayList<LauncherFile> get_files()
  {
    return launcherfiles;
  }

  /**
   * Returns the list of launcher files in reversed order.
   * Called from Roxenlauncher.Tray
   */
  public static ArrayList<LauncherFile> get_reversed_files()
  {
    ArrayList<LauncherFile> nlist = new Gee.ArrayList<LauncherFile>();

    for (int i = launcherfiles.size; i > 0;) {
      message("*** i is: %ld", i);
      nlist.add(launcherfiles.get(--i));
    }

    return nlist; 
  }
  
  /**
   * Adds a launcher file object to the list of files
   *
   * @param lf
   */
  public static void add_file(LauncherFile lf)
  {
    message("# Add launcher file (%s) to ArrayList", lf.get_uri());
    foreach (LauncherFile l in launcherfiles)
      if (l.get_uri() == lf.get_uri()) {
        warning("Launcher file exists. Skip adding!");
        return;
      }

    launcherfiles.add(lf);
  }
  
  /**
   * Remove file from the list of launcher files
   *
   * @param file
   */
  public static void remove_file(LauncherFile file)
  {
    launcherfiles.remove(file);
  }
  
  /**
   * Find the launcher file with URI uri
   *
   * @param uri
   * @return 
   *  The found LauncherFile object or null
   */
  public static LauncherFile? find_by_uri(string uri)
  {
    foreach (LauncherFile lf in launcherfiles)
      if (lf.get_uri() == uri)
        return lf;

    return null;
  }
  
  /**
   * Clear the list of launcher files
   */
  public static void clear_files()
  {
    launcherfiles.clear();
  }

  /**
   * Load already downloaded files
   */
  public static void load_existing()
  {
    if (launcherfiles == null)
      launcherfiles = new ArrayList<LauncherFile>();

    var p = getdir("files");

    try {
      var f = File.new_for_path(p).enumerate_children("standard::name", 
                                                      FileQueryInfoFlags.NONE,
                                                      null);
      FileInfo fi;
      while ((fi = f.next_file(null)) != null) {
        var lf = new LauncherFile.from_existing(fi.get_name(), null);
        launcherfiles.add(lf);
      }
    }
    catch (Error e) {
      warning("Failed to load launcher files: %s", e.message);
    }
  }
  
  /**
   * Handle incomming files
   *
   * @param data
   *  The raw file contents of a launcher stub file
   * @param file
   *  
   * @return
   *  false if the file already exists, true otherwise 
   */
  public static bool incomming(string data, out LauncherFile file) 
    throws RoxenError
  {
    string[] s = data.split("\r\n");
    
    if (s.length < 6) 
      throw new RoxenError.BAD_LAUNCHERFILE("Bad data in launcher file!");

    string ss = implode(slice(s, 0, 6), "\r\n");

    foreach (LauncherFile lf in launcherfiles) {
      var raw = implode(slice(lf.rawdata.split("\r\n"), 0, 6), "\r\n");
      if (raw == ss) {
        file = lf;
        file.download();
        return false;
      }
    }

    file = new LauncherFile(data);

    return true;
  }

  enum Statuses {
    DUMMY_STATUS,
    NOT_DOWNLOADED,
    DOWNLOADED,
    UPLOADED,
    NOT_UPLOADED,
    DOWNLOADING,
    UPLOADING,
    NOT_CHANGED
  }

  public string      rawdata        { get; private set; }
  public string      schema         { get; private set; }
  public string      host           { get; private set; }
  public string      port           { get; private set; }
  public string      auth_cookie    { get; private set; }
  public string      content_type   { get; private set; }
  public string      sb_params      { get; private set; }
  public string      id             { get; private set; }
  public string      path           { get; private set; }
  public string      local_dir      { get; private set; }
  public string      local_file     { get; private set; }
  public int         status         { get; private set; default = -1; }
  public bool        is_downloading { get; private set; default = false; }
  public bool        is_uploading   { get; private set; default = false; }
  public DateTime    last_upload    { get; private set; }
  public DateTime    last_download  { get; private set; }
  public DateTime    last_modified  { get; private set; }
  public DateTime    age            { get; private set; }
  public Application application    { get; private set; }

  //private DateTime null_date = new DateTime();
  
  /**
   * File monitor
   */
  private FileMonitor monitor;
  
  /**
   * Creates a new launcher file from a downloaded stub file
   *
   * @param data
   *  The contents of the stub file
   */
  public LauncherFile(string data) throws RoxenError
  {
#if DEBUG
    message("New incomming launcher file");
#endif
    rawdata = data;
    init(null); 
  }

  /**
   * Creates a new launcher file from an existing stub file
   *
   * @param id
   *  The directory name where the stub recides
   * @param data
   *  The contents of the stub file
   */
  public LauncherFile.from_existing(string id, string? data) throws RoxenError
  {
    this.id = id;
    rawdata = data == null ? load() : data;
    init(id);
  } 

  /**
   * Returns the file status as a string
   *
   * @return
   */
  public string status_as_string()
  {
    string s;
    switch (status)
    {
      case 1:  s = "Not downloaded"; break;
      case 2:  s = "Downloaded";     break;
      case 3:  s = "Uploaded";       break;
      case 4:  s = "Not uploaded";   break;
      case 5:  s = "Downloading..."; break;
      case 6:  s = "Uploading...";   break;
      case 7:  s = "Not changed";    break;
      default: s = "";               break;
    }

    return s;
  }
  
  /**
   * Returns the full remote URI of the file
   *
   * @return
   */
  public string get_uri()
  {
    var s = schema + "://" + host;
    
    if (schema == "https" && port != "443")
      s += port;
    else if (schema == "http" && port != "80")
      s += port;
      
    s += path;
    return s;
  }
  
  /**
   * Returns the cookie to send when downloading/uploading
   */
  public string get_cookie()
  {
    return "RoxenACauth=" + auth_cookie + "; " +
           "RoxenALparams=\"" + sb_params + "\"";
  }
  
  /**
   * Unset the application
   */
  public void unset_application()
  {
    application = null;
  }
  
  /**
   * Delete the file
   */
  public bool @delete()
  {
    bool retval = true;
    
    try {
      if (monitor != null)
        monitor.cancel();

      var dir = File.new_for_path(local_dir)
                    .enumerate_children("standard::name", 0, null);
      FileInfo fi;
      string fp;
      while ((fi = dir.next_file(null)) != null) {
        fp = Path.build_filename(local_dir, fi.get_name());
        File.new_for_path(fp).delete(null);
      }
      File.new_for_path(local_dir).delete(null);
    }
    catch (Error e) {
      warning("Failed to delete launcher file: %s!", e.message);
      retval = false;
    }
    
    return retval;
  }
  
  /**
   * Launches the file in its associated editor. If no editor is selected
   * yet the "Add editor" window will first be launched.
   */ 
  public void launch_editor()
  {
    if (application == null) {
      message("No application set for %s", local_file);
      var app = Application.get_for_mimetype(content_type);
      if (app == null) {
        application = win.editor_dialog_new(content_type);
        if (application == null)
          return;
      }
      else
        application = app;
    }

    if (!file_exists(local_file)) {
      download();
      return;
    }

    var cmd = application.command;
    if (application.arguments != null && application.arguments.length > 0)
      cmd += " " + application.arguments;

    cmd += " \"" + local_file + "\"";

    try {
      set_monitor();
	    Process.spawn_command_line_async(cmd);
      message("Spawned command");
    }
    catch (Error e) {
      warning("Error starting application: %s", e.message); 
    }
  }

  /**
   * Set monitor for local file
   */
  void set_monitor()
  {
    try {
      if (monitor != null)
        monitor.cancel();
        
      var f = File.new_for_path(local_file);
      monitor = f.monitor_file(FileMonitorFlags.NONE);
      monitor.changed += on_file_changed;
    }
    catch (Error e) {
      warning("Failed to set monitor for \"%s\"", local_file);
    }
  }
  
  /**
   * Stop the file monitor
   */
  void stop_monitor()
  {
    if (monitor != null)
      monitor.cancel();

    monitor = null;
  }

  /**
   * Download the file from the remote host
   */
  public void download(bool do_launch_editor=true)
  {
    message(">>> download()");

    if (status == Statuses.DOWNLOADING ||
        status == Statuses.UPLOADING) 
    {
      message("=== File under down/uploading ===");
      return;
    }
    
    stop_monitor();
    win_set_status(Statuses.DOWNLOADING);

    Idle.add(() => {
      HTTP.Response response = get_http_client().do_method("GET", null);  
      message("Download status code: %d", response.status_code);
      if (response.status_code != 200) {
        warning("Bad status in download: %ld", response.status_code);
        win_set_status(Statuses.NOT_DOWNLOADED);
        return false;
      }

      if (write_download_data(response)) {
        win_set_status(Statuses.DOWNLOADED);
        launch_editor();
      }
      else 
        warning("Unable to write downloaded data to disk!");

      save();
      return false;
    });
  }

  /**
   * Upload the file to the remote server
   */
  public void upload()
  {
    if (status == Statuses.DOWNLOADING ||
        status == Statuses.UPLOADING) 
    {
      message("=== File under up/donwloading ===");
      return;
    }

    win_set_status(Statuses.UPLOADING);

    message("> Do upload file...");

    Idle.add(() => {
      HTTP.Response response = get_http_client().do_method(
        "PUT", file_get_contents(local_file)
      );

      message("> File uploaded");

      if (response.status_code != 200) {
        message("> Bad status code (%d) in upload response!", response.status_code);
        win_set_status(Statuses.NOT_UPLOADED);
        return false;
      }

      last_upload = DateTime.now();
      win_set_status(Statuses.UPLOADED);
      save();
      return  false;
    });
  }
  
  /**
   * Write the response stream from the donwloaded file to the local file
   *
   * @param resp
   * @return
   */
  private bool write_download_data(HTTP.Response resp)
  {
    var tmpfile = Path.build_filename(getdir("$TMP"), 
                                      Path.get_basename(local_file) + ".tmp");
    try {
      var file = File.new_for_path(tmpfile);
      if (file_exists(tmpfile))
        file.delete(null);

      var fh = file.create(FileCreateFlags.NONE, null);
      var ds = new DataOutputStream(fh);
      foreach (uint8 c in resp.raw_data)
        ds.put_byte((uchar)c, null);

      var f = File.new_for_path(local_file);
      file.move(f, FileCopyFlags.OVERWRITE, null, null);
    }
    catch (Error e) {
      warning("Failed to save tmp file to disk: %s", e.message);
      return false;
    }
    
    return true;
  }

  /**
   * Set status for the file in the treeview
   *
   * @param st
   */
  private void  win_set_status(int st)
  {
    status = st;
    Idle.add(() => {
      win.set_file_status(this, status_as_string());
      return false;
    });
  }
  
  private HTTP.Request get_http_client()
  {
    HTTP.Request req = new HTTP.Request(get_uri());
    req.headers["User-Agent"] = App.USER_AGENT;
    req.headers["Translate"]  = "f";
    req.headers["Cookie"]     = get_cookie();
    req.keep_alive            = false;

#if DEBUG
    req.trace = true;
#endif

    return req;
  }

  /**
   * Initialize the file. Sets up directories and such and downloads the
   * real file from the remote host
   *
   * @param _id
   *  The directory name of the stub file
   */
  private void init(string? _id) throws RoxenError
  {
    if (rawdata == null || rawdata.length == 0)
      throw new RoxenError.BAD_LAUNCHERFILE("No data in launcher file!");
    
    string[] a = rawdata.split("\r\n");
    
    if (a.length < 7)
      throw new RoxenError.BAD_LAUNCHERFILE("Bad data in launcher file!");

    schema       = a[0];
    host         = a[1];
    port         = a[2];
    auth_cookie  = a[3];
    path         = a[4];
    content_type = a[5];
    sb_params    = a[6];
    
    if (a.length >= 9) {
      last_upload = DateTime.unixtime((time_t)a[7].to_long());
      status = a[8].to_int();
    }
    else {
      last_upload = new DateTime();
      status = Statuses.NOT_DOWNLOADED;
    }

    if (_id == null)
      randid();
      
    string[] p = path.split("/");
    local_dir = Path.build_filename(getdir("files"), id);
    local_file = Path.build_filename(local_dir, p[p.length-1]);

    if (_id == null) {
#if DEBUG
      message("First creation");
#endif
      Idle.add(() => {
        win.add_launcher_file(this);
        return false;
      });
      save();
      download();
    }
    else {
      if (!file_exists(local_file)) 
        download();
    
      var lm = filemtime(local_file);
      if (lm != null)
        last_modified = lm;
    }

    var _age = filectime(local_dir);
    if (_age != null)
      age = _age;
#if DEBUG
    message("End of LauncherFile.init()");
#endif
  }

  /**
   * Creates a random ID to use as directory name for a new launcher file
   *
   * @return 
   *  The ID created.
   */
  private void randid()
  {
    string sb = "";
    for (int i = 0; i < 8; i++)
      sb += "%c".printf((int)Math.floor(26 * Random.next_double() + 65));

    var p = trim(path, "/");

    string[] paths = p.split("/");
    string[] npaths = {};

    for (int i = 0; i < paths.length-1; i++)
      npaths += paths[i];

    if (npaths.length > 0)
      id = sb + "_" + implode(npaths, "_");
    else
      id = sb;

#if DEBUG
    message("New ID created: %s", id);
#endif
  }

  /**
   * Creates the directory where to store the stub file and the real file
   */
  private void create_dir()
  {
    var p = Path.build_filename(getdir("files"), id);
    if (!FileUtils.test(p, FileTest.EXISTS)) {
      if (DirUtils.create_with_parents(p, 0750) == -1)
        error("Unable to create directory for launcher file!");
    }
  }

  /**
   * Loads the stub file
   */
  private string load()
  {
    var p = Path.build_filename(getdir("files"), id, "stub");
    return file_get_contents(p);
  }
  
  /**
   * Saves the stub file
   */
  private void save()
  {
    create_dir();
    
    /*
    message("*** Schema:       %s",  schema);
    message("*** Host:         %s",  host);
    message("*** Port:         %s",  port);
    message("*** Auth cookie:  %s",  auth_cookie);
    message("*** Path:         %s",  path);
    message("*** Content type: %s",  content_type);
    message("*** SB params:    %s",  sb_params);
    message("*** Last upload:  %ld", last_upload.to_unixtime());
    message("*** Status:       %s",  status.to_string());
    */

    string[] data = {
      schema,
      host,
      port,
      auth_cookie,
      path,
      content_type,
      sb_params,
      "%ld".printf(last_upload.to_unixtime()),
      status.to_string()
    };

    try {
      var f = Path.build_filename(getdir("files"), id, "stub");
      FileUtils.set_contents(f, implode(data, "\r\n"));
    }
    catch (Error e) {
      warning("Failed to write stub file to local directory: %s", e.message);
    }
  }

  FileMonitorEvent previous_event;

  /**
   * Callback for the file monitor when the file is changed.
   *
   * @param f
   * @param other
   * @param e
   */
  private void on_file_changed(File f, File? other, FileMonitorEvent e)
  {
	  message("*** Changed...%d", e);
	  switch (e)
	  {
		  case FileMonitorEvent.ATTRIBUTE_CHANGED:
			  message("Attribute changed");
			  break;
			
		  case FileMonitorEvent.CHANGED:
			  message("File changed");
			  break;
			
		  case FileMonitorEvent.CHANGES_DONE_HINT:
			  message("Changes done hint");
			  if (previous_event == FileMonitorEvent.CREATED ||
			      previous_event == FileMonitorEvent.CHANGED)
			  {
			    upload();
			  }
			  else {
			    message("::: Don't upload: previous status: %d", previous_event);
			  }
			  break;
			
		  case FileMonitorEvent.CREATED:
			  message("File created");
			  break;
		
		  case FileMonitorEvent.DELETED:
			  message("File deleted");
			  break;
			
		  case FileMonitorEvent.PRE_UNMOUNT:
			  message("Pre unmounted");
			  break;
			
		  case FileMonitorEvent.UNMOUNTED:
			  message("Unmounted");
			  break;
			
		  default:
			  message("Why???");
			  break;
	  }
	  
	  previous_event = e;
  }
  
  ~LauncherFile()
  {
    message("Destructor called on launcher file");
    if (monitor != null)
      monitor.cancel();
  }
}