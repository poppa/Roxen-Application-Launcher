/* -*- Mode: Vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/*
 * launcherfile.vala
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

public class LauncherFile : Object
{
  /**
   * Soup.Message to use for all uploads and downloads. This only object is
   * used to have a Keep-Alive connection
   */
  private static Soup.Message httpmess = null;
  
  /**
   * Returns the Keep-Alive Soup.Message.
   *
   * @param method
   *  The HTTP method to use
   * @param uri
   *  The file to download or upload
   */
  public static Soup.Message get_http_message(string method, string uri)
  {
    if (httpmess == null)
      httpmess = new Soup.Message("GET", uri);

    httpmess.method = method;
    httpmess.set_uri(new Soup.URI(uri));
    httpmess.request_headers.clear();
    httpmess.request_headers.append("connection", "keep-alive");
    httpmess.request_body.truncate();

    return httpmess;
  }
   
  /**
   * Array of LauncherFiles
   */
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

    for (int i = launcherfiles.size; i > 0;)
      nlist.add(launcherfiles.get(--i));

    return nlist; 
  }
  
  /**
   * Adds a launcher file object to the list of files
   *
   * @param lf
   */
  public static void add_file(LauncherFile lf)
  {
    foreach (LauncherFile l in launcherfiles)
      if (l.get_uri() == lf.get_uri()) {
        message("Launcher file exists. Skip adding!");
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
      throw new RoxenError.BAD_LAUNCHERFILE(_("Bad data in launcher file!"));

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
  
  public enum NotifyType {
    UP,
    DOWN,
    ERROR
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
      case 1:  s = _("Not downloaded"); break;
      case 2:  s = _("Downloaded");     break;
      case 3:  s = _("Uploaded");       break;
      case 4:  s = _("Not uploaded");   break;
      case 5:  s = _("Downloading..."); break;
      case 6:  s = _("Uploading...");   break;
      case 7:  s = _("Not changed");    break;
      default: s = "";                  break;
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
      //monitor.changed += on_file_changed;
      monitor.changed.connect(on_file_changed);
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
    if (status == Statuses.DOWNLOADING ||
        status == Statuses.UPLOADING) 
    {
      return;
    }

    stop_monitor();
    win_set_status(Statuses.DOWNLOADING);

    Idle.add(() => {
      var sess = new Soup.SessionSync();
      //var mess = new Soup.Message("GET", get_uri());
      var mess = get_http_message("GET", get_uri());
      mess.request_headers.append("cookie", get_cookie());
      mess.request_headers.append("translate", "f");
      sess.send_message(mess);

      if (mess.status_code == Soup.KnownStatusCode.OK) {
        if (Soppa.save_soup_data(mess.response_body, local_file)) {
          win_set_status(Statuses.DOWNLOADED);
          win.show_notification(NotifyType.DOWN,
                                _("Download OK"),
                                _("%s was downloaded OK from %s")
                                .printf(path, host));
          launch_editor();
        }
        else {
          message("Unable to write downloaded data to file!");
          win_set_status(Statuses.NOT_DOWNLOADED);
          win.show_notification(NotifyType.ERROR,
                                _("Download failed"),
                                _("Unable to write downloaded data to file!"));
        }

        save();
      }
      else if (mess.status_code == Soup.KnownStatusCode.MOVED_PERMANENTLY ||
               mess.status_code == Soup.KnownStatusCode.MOVED_TEMPORARILY)
      {
        message("Redirection...follow!");
        win.show_notification(NotifyType.ERROR,
                              _("Unhandled redirection"), 
                              _("%s was not downloaded OK from %s")
                              .printf(path, host));
        win_set_status(Statuses.NOT_DOWNLOADED);
      }
      else {
        warning("Bad status (%ld) in download!", mess.status_code);
        win.show_notification(NotifyType.ERROR,
                              _("Download failed"), 
                              _("%s was not downloaded from %s")
                              .printf(path, host));
        win_set_status(Statuses.NOT_DOWNLOADED);
        save();
      }

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
      return;
    }

    win_set_status(Statuses.UPLOADING);

    Idle.add(() => {
			try {
				var sess = new Soup.SessionSync();
#if DEBUG
			  var logger  = new Soup.Logger(Soup.LoggerLogLevel.BODY, -1);
				sess.add_feature = logger;
#endif
			  //var mess = new Soup.Message("PUT", get_uri());
			  var mess = get_http_message("PUT", get_uri());
			  mess.request_headers.append("Cookie", get_cookie());
			  mess.request_headers.append("Translate", "f");

				IOChannel ch = new IOChannel.file(local_file, "r");
				ch.set_encoding(null); // Enables reading of binary data
				string s;
				size_t len;
				ch.read_to_end(out s, out len);

				mess.request_body.append(Soup.MemoryUse.COPY, s, len);
    		sess.send_message(mess);

		    last_upload = DateTime.now();
		    win_set_status(Statuses.UPLOADED);
		    win.show_notification(NotifyType.UP,
		                          _("Upload OK"), 
		                          _("%s was uploaded OK to %s")
		                          .printf(path, host));
			}
			catch (Error e) {
				message("Unable to upload file: %s", e.message);
				win_set_status(Statuses.NOT_UPLOADED);
				win.show_notification(NotifyType.ERROR,
		                          _("Upload failed"), 
		                          _("%s was not uploaded OK to %s")
		                          .printf(path, host));
			}

      save();
      return  false;
    });
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
      throw new RoxenError.BAD_LAUNCHERFILE(_("No data in launcher file!"));
    
    string[] a = rawdata.split("\r\n");
    
    if (a.length < 7)
      throw new RoxenError.BAD_LAUNCHERFILE(_("Bad data in launcher file!"));

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

    // No local copy available - first download
    if (_id == null) {
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
        error(_("Unable to create directory for launcher file!"));
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
#if DEBUG
	  message("*** Changed...%d", e);
#endif
	  switch (e)
	  {
		  case FileMonitorEvent.CHANGED:
#if DEBUG
			  message("File changed");
#endif
			  break;

		  case FileMonitorEvent.ATTRIBUTE_CHANGED:
#if DEBUG
			  message("Attribute changed");
#endif
        upload_on_change();
		    break;

		  case FileMonitorEvent.CHANGES_DONE_HINT:
#if DEBUG
			  message("Changes done hint");
#endif
        upload_on_change();
			  break;
			
		  case FileMonitorEvent.CREATED:
#if DEBUG
			  message("File created");
#endif
			  break;
		
		  case FileMonitorEvent.DELETED:
#if DEBUG
			  message("File deleted");
#endif
			  break;
			
		  case FileMonitorEvent.PRE_UNMOUNT:
#if DEBUG
			  message("Pre unmounted");
#endif
			  break;
			
		  case FileMonitorEvent.UNMOUNTED:
#if DEBUG
			  message("Unmounted");
#endif		  
			  break;
			
		  default:
#if DEBUG		  
			  message("Why???");
#endif
			  break;
	  }
	  
	  previous_event = e;
  }
  
  void upload_on_change()
  {
#if DEBUG
    message("Upload on change");
#endif

	  if (previous_event == FileMonitorEvent.CREATED ||
	      previous_event == FileMonitorEvent.CHANGED)
	  {
	    upload();
	  }
#if DEBUG
	  else {
	    message("::: Don't upload: previous status: %d", previous_event);
	  }
#endif
  }
  
  ~LauncherFile()
  {
#if DEBUG
    message("Destructor called on launcher file");
#endif    
    if (monitor != null)
      monitor.cancel();
  }
}
