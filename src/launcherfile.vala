/* -*- Mode: Vala; indent-tabs-mode: s; c-basic-offset: 2; tab-width: 2 -*- */
/* launcherfile.vala
 *
 * This file contains various utility methods and classes
 *
 * Copyright (C) 2010 Pontus Östlund
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 *  Pontus Östlund <pontus@poppa.se>
 */

public class Roxenlauncher.LauncherFile : Object
{
  /**
   * Storage for all current files
   */
  public static unowned List<LauncherFile> files {
    get;
    private set;
    default = new List<LauncherFile> ();
  }

  /**
   * Returns the list of launcher files in reversed order.
   * Called from Roxenlauncher.Tray
   */
  public static GLib.List<LauncherFile> get_reversed_files ()
  {
    GLib.List<LauncherFile> nlist = new GLib.List<LauncherFile> ();

    for (uint i = files.length (); i > 0;)
      nlist.append (files.nth_data (--i));

    return nlist;
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
    foreach (LauncherFile lf in files)
      if (lf.get_uri () == uri)
        return lf;

    return null;
  }

  /**
   * Load already downloaded files
   */
  public static void load_existing ()
  {
    var p = getdir ("files");

    try {
      var f = File.new_for_path (p).enumerate_children ("standard::name",
                                                        FileQueryInfoFlags.NONE,
                                                        null);
      FileInfo fi;

      while ((fi = f.next_file (null)) != null)
        files.append (new LauncherFile.from_existing (fi.get_name ()));
    }
    catch (GLib.Error e) {
      warning ("Failed to load launcher files: %s", e.message);
    }

    if (App.do_debug)
      message ("Num files: %ld", files.length ());
  }

  /**
   * Called from main when a new file is arriving
   *
   * @param data
   *  Contents of the downloaded .rxl2 file
   *
   * @return
   *  True if the file is new, false if it already exists locally
   */
  public static bool handle_file (string data, out LauncherFile lf)
    throws RoxenError
  {
    lf = null;
    string[] lines = data.split ("\r\n");

    if (lines.length < 7)
      throw new RoxenError.ANY(_("Bad data in launcher file!"));

    string hash = LauncherFile.make_hash (data);

    foreach (LauncherFile file in files) {
      if (file.rawdata != null) {
        string tmp = file.get_hash ();

        // File exists locally
        if (tmp == hash) {
          if (App.do_debug) message ("File exists");
          lf = file;
          return false;
        }
      }
    }

    lf = new LauncherFile (data);

    return true;
  }

  /**
   * Adds a launcher file object to the list of files
   *
   * @param lf
   */
  public static void add_file (LauncherFile lf)
  {
    foreach (LauncherFile l in files)
      if (l.get_uri () == lf.get_uri ()) {
        if (App.do_debug)
          message ("Launcher file exists. Skip adding!");

        return;
      }

    files.prepend (lf);
  }

  /**
   * Clear the list of launcher files
   */
  public static void clear_files ()
  {
    foreach (LauncherFile l in files)
      files.remove (l);

    files = new GLib.List<LauncherFile> ();
  }

  /**
   * Remove file from the list of launcher files
   *
   * @param file
   */
  public static void remove_file (LauncherFile file)
  {
    files.remove (file);
  }

  /**
   * Makes a hash from a stub file. This is for comparing if one file is
   * the same as another.
   *
   * @param stub
   *  The raw data of a stub file
   */
  public static string make_hash (string stub)
  {
    string[] t = stub.split ("\r\n");
    assert (t.length > 4);
    string s = t[1] + t[2] + t[4] + t[5];
    return Checksum.compute_for_string(ChecksumType.MD5, s, s.length);
  }

  /**
   * Raw file content
   */
  public string? rawdata { get; private set; default = null; }

  /**
   * HTTP schema used for this file
   */
  public string schema { get; private set; }

  /**
   * Host the file was downloaded from
   */
  public string host { get; private set; }

  /**
   * Port used for this file
   */
  public int port { get; private set; }

  /**
   * Authentication cookie
   */
  public string auth_cookie { get; private set; }

  /**
   * Content type of the file on the Roxen server
   */
  public string content_type { get; private set; }

  /**
   * Params cookie for the SiteBuilder
   */
  public string sb_params { get; private set; }

  /**
   * The directory name where the file exists on the local FS
   */
  public string? id { get; private set; default = null; }

  /**
   * File path on the Roxen server
   */
  public string path { get; private set; }

  /**
   * Path to the local directory
   */
  public string local_dir { get; private set; }

  /**
   * Path to the local file
   */
  public string local_file { get; private set; }

  /**
   * File status
   */
  public int status { get; private set; default = -1; }

  /**
   * List of bundled files (used by Roxen Editorial Portal)
   */
  public string[] bundle_paths { get; private set; }

  /**
   * Is the file being downloaded?
   */
  public bool is_downloading { get; private set; default = false; }

  /**
   * Is the file being uploaded?
   */
  public bool is_uploading { get; private set; default = false; }

  /**
   * When was the file last uploaded
   */
  public DateTime? last_upload { get; private set; default = null; }

  /**
   * When was the file last downloaded?
   */
  public DateTime? last_download { get; private set; default = null; }

  /**
   * When was the file last modified
   */
  public DateTime? last_modified  { get; private set; default = null; }

  /**
   * Content type object for the file. Contains the editor to use
   * for the file
   */
  public ContentType application { get; private set; }

  /**
   * Monitors changes to the file and invokes file upload on changes.
   */
  private FileMonitor monitor;

  /**
   * File statuses
   */
  public enum Statuses {
    DUMMY_STATUS,
    NOT_DOWNLOADED,
    DOWNLOADED,
    UPLOADED,
    NOT_UPLOADED,
    DOWNLOADING,
    UPLOADING,
    NOT_CHANGED
  }

  /**
   * Notification types
   */
  public enum NotifyType {
    UP,
    DOWN,
    ERROR
  }

  /**
   * Constructor for a launcherfile that doesn't exist locally
   *
   * @param data
   *  The raw data of the .rxl2 file
   */
  public LauncherFile (string data)
  {
    rawdata = data;
    assert (rawdata.length > 0);
    init ();
  }

  /**
   * Constructor for a launcherfile that exists locally
   *
   * @param id
   *  The directory name of the file on the local FS
   * @param data
   */
  public LauncherFile.from_existing (string id, string? data=null)
  {
    this.id = id;
    rawdata = data == null ? load () : data;

    if (rawdata == null || rawdata.length == 0) {
      error ("%s seems bad. Try cleaning up the files directory at \"%s\"",
             id, getdir ("files"));
    }

    init ();
  }

  /**
   * Unset the application
   */
  public void unset_application ()
  {
    application = null;
  }

  /**
   * Returns the full remote URI of the file
   *
   * @return
   */
  public string get_uri (string? _path=null)
  {
    var s = schema + "://" + host;

    if (schema == "https" && port != 443)
      s += ":" + port.to_string ();
    else if (schema == "http" && port != 80)
      s += ":" + port.to_string ();

    return s + (_path == null ? path : _path);
  }

  /**
   * Returns the URI to the file in Sitebuilder
   */
  public string get_sb_uri ()
  {
    var s = schema + "://" + host;

    if (schema == "https" && port != 443)
      s += ":" + port.to_string ();
    else if (schema == "http" && port != 80)
      s += ":" + port.to_string ();

    return s + ("/edit" + path);
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
   * Returns the first six lines of the stub file
   */
  public string[]? get_header ()
  {
    if (rawdata == null) return null;

    string[] t = rawdata.split ("\r\n");
    string[] ret = new string[7];

    for (int i = 0; i < 7; i++)
      ret[i] = t[i];

    return ret;
  }

  /**
   * Returns the file hash. This is not a hash of the entire file but some
   * parts of the raw stub file.
   */
  public string get_hash ()
  {
    if (_hash == null)
      _hash = LauncherFile.make_hash (rawdata);

    return _hash;
  } private string _hash = null;

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
   * Parse the rxl2 file, set up directories and stuff like that
   */
  void init ()
  {
    string _id   = id;
    string[] a   = rawdata.split ("\r\n");

    // Default fields
    schema       = a[0];
    host         = a[1];
    port         = int.parse (a[2]);
    auth_cookie  = a[3];
    path         = a[4];
    content_type = a[5];
    sb_params    = a[6];

    if (a.length >= 9) {
      if (long.parse (a[7]) > 0)
        last_upload = new DateTime.from_unix_local ((time_t) long.parse (a[7]));

      status = int.parse (a[8]);

      if (a.length > 9 && a[9].length > 0)
        bundle_paths = a[9].split (":");
    }
    else {
      status = Statuses.NOT_DOWNLOADED;
    }

    if (_id == null)
      randid ();

    string fn  = File.new_for_path (path).get_basename ();
    local_dir  = Path.build_filename (getdir ("files"), id);
    local_file = Path.build_filename (getdir ("files"), id, fn);

    if (!Poppa.file_exists (local_file)) {
      save ();

      Idle.add (() => {
        window.add_launcher_file (this);
        return false;
      });
    }
    else {
      var lm = Poppa.filemtime (local_file);

      if (lm != null)
        last_modified = lm;
    }

    if (App.do_debug)
      message ("LauncherFile.init (%s): Done!", get_uri ());
  }

  /**
   * Set file status and update file in treeview
   */
  void win_set_status (int st)
  {
    status = st;

    Idle.add(() => {
      window.set_file_status (this, status_as_string ());
      return false;
    });
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

  /**
   * Launch the editor asynchronously
   */
  public async void launch_editor_async ()
  {
    launch_editor ();
    yield;
  }

  /**
   * Launches the file in its associated editor. If no editor is selected
   * yet the "Add editor" window will first be launched.
   */
  public void launch_editor ()
  {
    if (App.do_debug)
      message ("Launch editor for ct %s", content_type);

    if (application == null) {
      var app = ContentType.get_by_ct (content_type);

      if (app == null) {
        application = window.ct_new (content_type);

        if (application == null)
          return;
      }
      else
        application = app;
    }

    if (!Poppa.file_exists (local_file)) {
      download ();
      yield;
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
      window.show_notification (NotifyType.ERROR,
                                _("Error starting editor"),
                                _("Could not start editor %s: %s ")
                                .printf (application.editor.name,
                                         e.message));
      log_warning (_("Could not start editor %s: %s ")
                    .printf (application.editor.name, e.message));
    }

    yield;
  }

  /**
   * Download the file
   */
  public async void download ()
  {
    if (status == Statuses.DOWNLOADING || status == Statuses.UPLOADING) {
      log_message ("Downloading or Uploading. Skipping donwload...");
      return;
    }

    stop_monitor ();

    log_message (_("Downloading file: %s").printf (get_uri ()));

    win_set_status (Statuses.DOWNLOADING);

    Soup.SessionSync sess = new Soup.SessionSync ();

    if (App.do_debug) {
      message ("Adding logger to SOUP Session");
      sess.add_feature (new Soup.Logger (Soup.LoggerLogLevel.HEADERS, -1));
    }

    if (App.do_debug)
      print ("> %s\n", get_uri ());

    sess.queue_message (get_http_message ("GET", get_uri ()), low_download);

    yield;
  }

  /**
   * Fetch the file
   */
  void low_download (Soup.Session sess, Soup.Message mess)
  {
    if (mess.status_code == Soup.KnownStatusCode.OK) {
      if (App.do_debug)
        message ("Download ok");

      if (save_downloaded_file (mess.response_body.data)) {
        win_set_status (Statuses.DOWNLOADED);

        window.show_notification (NotifyType.DOWN,
                                  _("Download OK"),
                                  _("%s was downloaded OK from %s")
                                  .printf (path, host));

        launch_editor_async.begin ();
      }

      save ();
    }
    else if (mess.status_code == Soup.KnownStatusCode.MOVED_PERMANENTLY ||
             mess.status_code == Soup.KnownStatusCode.MOVED_TEMPORARILY)
    {
      message ("Follow redirect...");
      log_message ("Got redrirect. Not implemented yet!");
      win_set_status (Statuses.NOT_DOWNLOADED);
    }
    else {
      if (App.do_debug)
        warning ("Bad status code in HTTP response");

      string s;

      switch (mess.status_code)
      {
        case 404:
          s = _("Requested file %s not found on %s").printf (path, host);
          break;

        default:
          s = _("%s was not downloaded from %s (code: %d)").printf (path, host, mess.status_code);
          break;
      }

      if (App.do_debug)
        message ("Download failed: %s", s);

      log_warning (s);
      win_set_status (Statuses.NOT_DOWNLOADED);
      window.show_notification (NotifyType.ERROR, _("Download failed"), s);
      save ();
    }
  }

  /**
   * Save the downloaded file to disk
   */
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
      fs = null;
    }
    catch (GLib.Error e) {
      log_warning (_("Unable to write to file %s: %s")
                    .printf (local_file, e.message));

      return false;
    }

    return true;
  }

  /**
   * Upload the file to the remote server
   */
  public async void upload ()
  {
    if (status == Statuses.DOWNLOADING || status == Statuses.UPLOADING)
      return;

    if (App.do_debug)
      print ("> %s\n", get_uri ());

    log_message (_("Uploading %s").printf (get_uri ()));
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

      if (App.do_debug)
        sess.add_feature (new Soup.Logger (Soup.LoggerLogLevel.HEADERS, -1));

      var mess = get_http_message ("PUT", get_uri ());
      mess.request_body.append (Soup.MemoryUse.COPY, data);

      sess.queue_message (mess, on_upload);
      yield;
    }
    catch (GLib.Error e) {
      log_warning (_("Unable to upload file: %s").printf (e.message));
      win_set_status (Statuses.NOT_UPLOADED);
      window.show_notification (NotifyType.ERROR,
                                _("Upload failed"),
                                _("%s was not uploaded OK to %s")
                                .printf (path, host));
    }
  }

  void on_upload (Soup.Session sess, Soup.Message mess)
  {
    last_upload = new DateTime.now_local ();

    win_set_status (Statuses.UPLOADED);

    window.show_notification (NotifyType.UP,
                              _("Upload OK"),
                              _("%s was uploaded OK to %s")
                              .printf (path, host));
    save ();

    window.set_file_selection (this);

    mess = null;
    sess = null;
  }

  /**
   * Creates a Soup.Message with some defaults set
   *
   * @param method
   * @param uri
   */
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
   * Saves the stub file
   */
  private void save ()
  {
    create_dir ();
    string bp = "";
    string lu = "";

    if (last_upload == null)
      lu = "0";
    else
      lu = "%lld".printf (last_upload.to_unix ());

    if (bundle_paths != null)
      bp = string.joinv (":", bundle_paths);

    string[] data = {
      schema,
      host,
      port.to_string (),
      auth_cookie,
      path,
      content_type,
      sb_params,
      lu,
      status.to_string (),
      bp
    };

    try {
      var f = Path.build_filename (getdir ("files"), id, "stub");
      FileUtils.set_contents (f, string.joinv ("\r\n", data));
    }
    catch (GLib.Error e) {
      warning ("Failed to write stub file to local directory: %s", e.message);
    }
  }

  /**
   * Creates a random string used as directory name on the local FS
   */
  void randid ()
  {
    string sb = host + "_";
    for (int i = 0; i < 8; i++)
      sb += "%c".printf ((int) Math.floor (26 * Random.next_double () + 65));

    string[] paths = path[1:path.length-1].split ("/");
    paths = paths[0:paths.length-1];

    assert (paths != null);

    if (paths.length > 0)
      id = sb + "_" + string.joinv ("_", paths);
    else
      id = sb;
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
    return Poppa.file_get_contents (p);
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
      upload.begin ();
    }
  }

  ~LauncherFile ()
  {
    message ("LauncherFile destroyed: %s", get_uri ());

    if (monitor != null)
      monitor.cancel ();
  }
}
