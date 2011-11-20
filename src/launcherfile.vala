/* -*- Mode: Vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* launcherfile.vala
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

public class Roxenlauncher.LauncherFile : Object
{   
  /**
   * Array of LauncherFiles
   */
  private static GLib.List<LauncherFile> launcherfiles =
    new GLib.List<LauncherFile> ();

  /**
   * Returns the list of launcher files
   * 
   * @return
   */
  public static unowned GLib.List<LauncherFile> get_files ()
  {
    return launcherfiles;
  }

  /**
   * Returns the list of launcher files in reversed order.
   * Called from Roxenlauncher.Tray
   */
  public static GLib.List<LauncherFile> get_reversed_files ()
  {
    GLib.List<LauncherFile> nlist = new GLib.List<LauncherFile> ();

    for (uint i = launcherfiles.length (); i > 0;)
      nlist.append (launcherfiles.nth_data (--i));

    return nlist; 
  }
  
  /**
   * Adds a launcher file object to the list of files
   *
   * @param lf
   */
  public static void add_file (LauncherFile lf)
  {
    foreach (LauncherFile l in launcherfiles)
      if (l.get_uri () == lf.get_uri ()) {
#if DEBUG
        message ("Launcher file exists. Skip adding!");
#endif
        return;
      }

    launcherfiles.prepend (lf);
  }
  
  /**
   * Remove file from the list of launcher files
   *
   * @param file
   */
  public static void remove_file (LauncherFile file)
  {
    launcherfiles.remove (file);
  }

  /**
   * Find the launcher file with URI uri
   *
   * @param uri
   * @return 
   *  The found LauncherFile object or null
   */
  public static LauncherFile? find_by_uri (string uri)
  {
    foreach (LauncherFile lf in launcherfiles)
      if (lf.get_uri () == uri)
        return lf;

    return null;
  }
  
  /**
   * Clear the list of launcher files
   */
  public static void clear_files ()
  {
    foreach (LauncherFile l in launcherfiles)
    	launcherfiles.remove (l);

    launcherfiles = new GLib.List<LauncherFile> ();
  }

  /**
   * Load already downloaded files
   */
  public static void load_existing ()
  {
    if (launcherfiles == null)
      launcherfiles = new GLib.List<LauncherFile> ();

    var p = getdir ("files");

    try {
      var f = File.new_for_path (p).enumerate_children ("standard::name", 
                                                        FileQueryInfoFlags.NONE,
                                                        null);
      FileInfo fi;
      while ((fi = f.next_file (null)) != null) {
        var lf = new LauncherFile.from_existing (fi.get_name (), null);
        launcherfiles.append (lf);
      }
    }
    catch (GLib.Error e) {
      warning ("Failed to load launcher files: %s", e.message);
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
  public static bool incomming (string data, out LauncherFile file) 
    throws RoxenError
  {
    string[] s = data.split ("\r\n");
    
    if (s.length < 6) 
      throw new RoxenError.BAD_LAUNCHERFILE (_("Bad data in launcher file!"));

		try {
		  string ss = array_implode (array_slice (s, 0, 6), "\r\n");

		  foreach (LauncherFile lf in launcherfiles) {
		    var raw = array_implode (array_slice (lf.rawdata.split ("\r\n"), 0, 6), 
		                             "\r\n");
		    if (raw == ss) {
		      file = lf;
		      file.download ();
		      return false;
		    }
		  }

		  file = new LauncherFile (data);

		  return true;
		}
		catch (Poppa.Error e) {
			throw new RoxenError.BAD_LAUNCHERFILE (_("Bad data in launcher file!"));
		}
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

  public string         rawdata        { get; private set; }
  public string         schema         { get; private set; }
  public string         host           { get; private set; }
  public string         port           { get; private set; }
  public string         auth_cookie    { get; private set; }
  public string         content_type   { get; private set; }
  public string         sb_params      { get; private set; }
  public string         id             { get; private set; }
  public string         path           { get; private set; }
  public string         local_dir      { get; private set; }
  public string         local_file     { get; private set; }
  public int            status         { get; private set; default = -1; }
  public string[]       bundle_paths   { get; private set; }
  public bool           is_downloading { get; private set; default = false; }
  public bool           is_uploading   { get; private set; default = false; }
  public Poppa.DateTime last_upload    { get; private set; }
  public Poppa.DateTime last_download  { get; private set; }
  public Poppa.DateTime last_modified  { get; private set; }
  public ContentType    application    { get; private set; }

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
  public LauncherFile (string data) throws RoxenError
  {
    rawdata = data;
    init (null);
  }

  /**
   * Creates a new launcher file from an existing stub file
   *
   * @param id
   *  The directory name where the stub recides
   * @param data
   *  The contents of the stub file
   */
  public LauncherFile.from_existing (string id, string? data) throws RoxenError
  {
    this.id = id;
    rawdata = data == null ? load () : data;
    init (id);
  } 

  /**
   * Returns the file status as a string
   *
   * @return
   */
  public string status_as_string ()
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
  public string get_uri (string? _path=null)
  {
    var s = schema + "://" + host;
    
    if (schema == "https" && port != "443")
      s += ":" + port;
    else if (schema == "http" && port != "80")
      s += ":" + port;

    s += _path == null ? path : _path;
    return s;
  }
  
  /**
   * Returns the URI to the file in Sitebuilder
   */
  public string get_sb_uri ()
  {
  	var s = schema + "://" + host;
    if (schema == "https" && port != "443")
      s += ":" + port;
    else if (schema == "http" && port != "80")
      s += ":" + port;
      
    s += "/edit" + path;
    return s;
  }

  /**
   * Returns the cookie to send when downloading/uploading
   */
  public string get_cookie ()
  {
    return "RoxenACauth=" + auth_cookie + "; " +
           "RoxenALparams=\"" + sb_params + "\"";
  }
  
  /**
   * Unset the application
   */
  public void unset_application ()
  {
    application = null;
  }
  
  /**
   * Delete the file
   */
  public bool @delete ()
  {
    bool retval = true;
    
    try {
      if (monitor != null)
        monitor.cancel ();

      var dir = File.new_for_path (local_dir)
                    .enumerate_children ("standard::name", 0, null);
      FileInfo fi;
      string fp;
      while ((fi = dir.next_file (null)) != null) {
        fp = Path.build_filename (local_dir, fi.get_name ());
        File.new_for_path (fp).delete (null);
      }
      File.new_for_path (local_dir).delete (null);
    }
    catch (GLib.Error e) {
      warning ("Failed to delete launcher file: %s!", e.message);
      retval = false;
    }
    
    return retval;
  }
  
  /**
   * Launches the file in its associated editor. If no editor is selected
   * yet the "Add editor" window will first be launched.
   */ 
  public void launch_editor ()
  {

		message ("Launch editor for ct %s", content_type);
		
    if (application == null) {
      var app = ContentType.get_by_ct (content_type);

      if (app == null) {
				
        application = Main.window.ct_new (content_type);

        if (application == null)
          return;
      }
      else
        application = app;
    }

    if (!file_exists (local_file)) {
      download ();
      return;
    }

    var cmd = application.editor.command;

		try {
			var l = new List<File> ();
			l.append (File.new_for_path (local_file));

			set_monitor ();

			AppInfo ai = AppInfo.create_from_commandline (cmd, null, 
			                                              AppInfoCreateFlags.NONE);
			ai.launch (l, null);
		}
		catch (GLib.Error e) {
			Main.window.show_notification (NotifyType.ERROR,
			                               _("Error starting editor"),
			                               _("Could not start editor %s: %s ")
			                               .printf (application.editor.name, 
			                                        e.message));
		}
  }

  /**
   * Set monitor for local file
   */
  void set_monitor ()
  {
    try {
      if (monitor != null)
        monitor.cancel ();
        
      var f = File.new_for_path (local_file);
      monitor = f.monitor_file (FileMonitorFlags.NONE);
      monitor.changed.connect (on_file_changed);
    }
    catch (GLib.Error e) {
      warning ("Failed to set monitor for \"%s\"", local_file);
    }
  }
  
  /**
   * Stop the file monitor
   */
  void stop_monitor ()
  {
    if (monitor != null)
      monitor.cancel ();

    monitor = null;
  }

	Soup.Message get_http_message (string method, string uri)
	{
		Soup.Message mess;
		weak Soup.Message http_mess;

		mess = new Soup.Message (method, uri);
		http_mess = mess;
		
		http_mess.request_headers.append ("Cookie", get_cookie ());
		http_mess.request_headers.append ("Translate", "f");

		return http_mess;
	}
	
  /**
   * Download the file from the remote host
   */
  public void download (bool do_launch_editor=true)
  {
    if (status == Statuses.DOWNLOADING || status == Statuses.UPLOADING) {
      return;
    }

    stop_monitor ();
    win_set_status (Statuses.DOWNLOADING);

	  Soup.Session sess = new Soup.SessionSync ();

		if (Main.do_debug)
			sess.add_feature = new Soup.Logger (Soup.LoggerLogLevel.HEADERS, -1);

		Logger.message (_("Downloading file: %s").printf (get_uri()));

		if (Main.do_debug)
			print ("< %s\n", get_uri ());

		sess.queue_message (get_http_message ("GET", get_uri()), on_download);
  }
	
	void on_download (Soup.Session sess, Soup.Message mess)
	{
    if (mess.status_code == Soup.KnownStatusCode.OK) {
      if (save_downloaded_file (mess.response_body.data)) {
      	if (bundle_paths != null) {
					Soup.Session lsess = new Soup.SessionSync ();

      		foreach (string bp in bundle_paths) {
      			var lmess = get_http_message ("GET", get_uri(bp));
      			lsess.send_message (lmess);

      			if (lmess.status_code == Soup.KnownStatusCode.OK) {
      				string lp = bp;
      				if (lp.contains ("?"))
      					lp = lp.substring (0, lp.index_of ("?"));

      				string[] parts = lp.split ("/");
      				lp = local_dir + "/" + parts[parts.length-1];
#if DEBUG
      				print ("Saving bundle: %s\n", lp);
#endif
							save_downloaded_file (lmess.response_body.data, lp);

							lmess = null;
      			}
      			else {
      				warning ("Download of bundle file %s failed", bp);
							Logger.message (_("Download of bundle file %s failed")
							                .printf(bp));
      			}
      		}
      	}

				win_set_status (Statuses.DOWNLOADED);

				Idle.add (() => {
		      Main.window.show_notification (NotifyType.DOWN,
		                                     _("Download OK"),
		                                     _("%s was downloaded OK from %s")
		                                     .printf(path, host));
      		launch_editor ();
					return false;
				});
      }
      else {
        win_set_status (Statuses.NOT_DOWNLOADED);
        Main.window.show_notification (
        	NotifyType.ERROR,
          _("Download failed"),
          _("Unable to write downloaded data to file!"));
      }

      save ();
    }
    else if (mess.status_code == Soup.KnownStatusCode.MOVED_PERMANENTLY ||
             mess.status_code == Soup.KnownStatusCode.MOVED_TEMPORARILY)
    {
#if DEBUG
      print ("* Redirection...follow!\n");
#endif
      Main.window.show_notification (NotifyType.ERROR,
                                     _("Unhandled redirection"), 
                                     _("%s was not downloaded OK from %s")
                                     .printf (path, host));
      win_set_status (Statuses.NOT_DOWNLOADED);
    }
    else {
			Logger.warning (_("Bad status (%ld) in download!")
			                .printf (mess.status_code));

      string s;

      switch (mess.status_code)
      {
      	case 404:
      		s = _("Requested file %s not found on %s").printf (path, host);
      		break;

      	default:
      		s = _("%s was not downloaded from %s").printf (path, host);
      		break;
      }

			Logger.warning (s);

      Main.window.show_notification (NotifyType.ERROR,_("Download failed"), s);
      win_set_status (Statuses.NOT_DOWNLOADED);
      save ();
    }

		mess = null;
		sess = null;
	}

  /**
   * Upload the file to the remote server
   */
  public void upload ()
  {
    if (status == Statuses.DOWNLOADING || status == Statuses.UPLOADING) {
      return;
    }

		if (Main.do_debug)
			print ("> %s\n", get_uri ());
		
		Logger.message (_("Uploading %s").printf (get_uri ()));
    win_set_status (Statuses.UPLOADING);

		try {
			var f = File.new_for_path (local_file);
			var s = new DataInputStream (f.read());
			var i = f.query_info ("*", FileQueryInfoFlags.NONE);

			int64 fsize = i.get_size ();
			uint8[] data = new uint8[fsize];

			s.read (data);
			s.close ();
			s = null;

			var sess = new Soup.SessionSync ();

			if (Main.do_debug)
				sess.add_feature = new Soup.Logger (Soup.LoggerLogLevel.HEADERS, -1);

			var mess = get_http_message ("PUT", get_uri ());
			mess.request_body.append (Soup.MemoryUse.COPY, data);

			sess.queue_message (mess, on_upload); 
		}
		catch (GLib.Error e) {
			Logger.warning (_("Unable to upload file: %s").printf(e.message));
			win_set_status (Statuses.NOT_UPLOADED);
			Main.window.show_notification (NotifyType.ERROR,
	                                   _("Upload failed"), 
	                                   _("%s was not uploaded OK to %s")
	                                     .printf(path, host));
		}
  }

	void on_upload (Soup.Session sess, Soup.Message mess)
	{
		last_upload = Poppa.DateTime.now ();

		win_set_status (Statuses.UPLOADED);

		Main.window.show_notification (NotifyType.UP,
			                             _("Upload OK"), 
			                             _("%s was uploaded OK to %s")
			                             .printf (path, host));
		save();

		mess = null;
		sess = null;
	}

	bool save_downloaded_file (uint8[] data, string? path=null)
	{
		path = path == null ? local_file : path;

		var f = File.new_for_path (path);
		FileIOStream fs;

		try {
			if (f.query_exists (null)) {
				fs = f.open_readwrite (null);
				fs.truncate_fn (0, null);
			}
			else
				fs = f.create_readwrite (FileCreateFlags.PRIVATE);

			fs.output_stream.write (data, null);
			fs.close (null);
		}
		catch (GLib.Error e) {
			Logger.warning (_("Unable to write to file %s: %s")
			                .printf (local_file, e.message));

			return false;
		}

		return true;
	}
	
  /**
   * Set status for the file in the treeview
   *
   * @param st
   */
  private void  win_set_status (int st)
  {
    status = st;
    Idle.add (() => {
      Main.window.set_file_status (this, status_as_string ());
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
  private void init (string? _id) throws RoxenError
  {
    if (rawdata == null || rawdata.length == 0)
      throw new RoxenError.BAD_LAUNCHERFILE (_("No data in launcher file!"));

    string[] a = rawdata.split ("\r\n");

    if (a.length < 7)
      throw new RoxenError.BAD_LAUNCHERFILE (_("Bad data in launcher file!"));

    schema       = a[0];
    host         = a[1];
    port         = a[2];
    auth_cookie  = a[3];
    path         = a[4];
    content_type = a[5];
    sb_params    = a[6];

    if (a.length >= 9) {
      last_upload = Poppa.DateTime.unixtime ((time_t) long.parse (a[7]));
      status = int.parse (a[8]);
      if (a.length > 9 && a[9].length > 0)
      	bundle_paths = a[9].split (":");
    }
    else {
      last_upload = new Poppa.DateTime ();
      status = Statuses.NOT_DOWNLOADED;
    }

    if (_id == null)
      randid ();

    string[] p = path.split ("/");
    local_dir  = Path.build_filename (getdir ("files"), id);
    local_file = Path.build_filename (local_dir, p[p.length-1]);

    // No local copy available - first download
    if (_id == null) {
      Idle.add (() => {
				Main.window.add_launcher_file (this);
        return false;
      });

			save ();
      download (); 
		}
    else {
      var lm = filemtime (local_file);
      if (lm != null)
        last_modified = lm;
    }

#if DEBUG
    message ("End of LauncherFile.init()");
#endif
  }

  /**
   * Creates a random ID to use as directory name for a new launcher file
   *
   * @return
   *  The ID created.
   */
  private void randid ()
  {
    string sb = "";
    for (int i = 0; i < 8; i++)
      sb += "%c".printf ((int) Math.floor (26 * Random.next_double () + 65));

    var p = trim (path, "/");

    string[] paths = p.split ("/");
    string[] npaths = {};

    for (int i = 0; i < paths.length-1; i++)
      npaths += paths[i];

    if (npaths.length > 0)
      id = sb + "_" + array_implode (npaths, "_");
    else
      id = sb;

#if DEBUG
    message ("New ID created: %s", id);
#endif
  }

  /**
   * Creates the directory where to store the stub file and the real file
   */
  private void create_dir ()
  {
    var p = Path.build_filename (getdir ("files"), id);
    if (!FileUtils.test (p, FileTest.EXISTS)) {
      if (DirUtils.create_with_parents (p, 0750) == -1)
        error (_("Unable to create directory for launcher file!"));
    }
  }

  /**
   * Loads the stub file
   */
  private string load ()
  {
    var p = Path.build_filename (getdir ("files"), id, "stub");
    return file_get_contents (p);
  }

  /**
   * Saves the stub file
   */
  private void save ()
  {
    create_dir ();
		string bp = "";

		if (bundle_paths != null)
			bp = array_implode (bundle_paths, ":");

    string[] data = {
      schema,
      host,
      port,
      auth_cookie,
      path,
      content_type,
      sb_params,
      "%ld".printf (last_upload.to_unixtime ()),
      status.to_string (),
      bp
    };

    try {
      var f = Path.build_filename (getdir ("files"), id, "stub");
      FileUtils.set_contents (f, array_implode (data, "\r\n"));
    }
    catch (GLib.Error e) {
      warning ("Failed to write stub file to local directory: %s", e.message);
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
  private void on_file_changed (File f, File? other, FileMonitorEvent e)
  {
	  switch (e)
	  {
		  case FileMonitorEvent.ATTRIBUTE_CHANGED:
        upload_on_change ();
		    break;

		  case FileMonitorEvent.CHANGES_DONE_HINT:
        upload_on_change ();
			  break;
	  }

	  previous_event = e;
  }

  void upload_on_change ()
  {
	  if (previous_event == FileMonitorEvent.CREATED ||
	      previous_event == FileMonitorEvent.CHANGED)
	  {
	    upload ();
	  }
  }

  ~LauncherFile ()
  {
		message ("LauncherFile destroyed: %s", get_uri ());

    if (monitor != null)
      monitor.cancel ();
  }
}
