/* -*- Mode: Vala; indent-tabs-mode: s; c-basic-offset: 2; tab-width: 2 -*- */
/*
 * mainwindow.vala
 * Copyright (C) Pontus Östlund 2009-2015 <poppanator@gmail.com>
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

using Notify;
using Poppa;

public class Roxenlauncher.MainWindow : Gtk.Window
{
  Gtk.Builder           builder;
  Gtk.VBox              main_vbox;
  Gtk.ScrolledWindow    sw_files;
  Gtk.CheckButton       cb_notify;
  Gtk.CheckButton       cb_minimize;
  Gtk.CheckButton       cb_logging;
  Gtk.CheckButton       cb_allow_any_cert;
  Gtk.Button            btn_edit_file;
  Gtk.Button            btn_finish_file;
  Gtk.Button            btn_finish_all;
  Gtk.Button            btn_edit_app;
  Gtk.Button            btn_add_app;
  Gtk.Button            btn_remove_app;
  Gtk.Button            btn_clear_log;
  Gtk.TreeView          tv_files;
  Gtk.TreeView          tv_apps;
  Gtk.ListStore         ls_files;
  Gtk.ListStore         ls_apps;
  Gtk.Statusbar         statusbar;
  Gtk.Menu              ctx_menu;
  Gtk.FileChooserButton fcb_logfile;
  Gtk.TextView          logview;
  Gtk.SpinButton        sp_timeout;

  //Tray tray;

  /**
   * Column order for the content type tree view
   */
  enum TVCtCols {
    MIMETYPE,
    ICON,
    EDITOR,
    CONTENT_TYPE,
    N_COLS
  }

  /**
   * Column order for the file tree view
   */
  enum TVFileCols {
    URI,
    STATUS,
    LAST_UPLOAD,
    LAUNCHERFILE,
    N_COLS
  }

  /**
   * Construct the UI
   */
  public bool setup_ui ()
  {
    builder = new Gtk.Builder ();
    string? filename = get_ui_path (MAIN_UI_FILENAME);

    if (filename == null)
      error ("Unable to load GUI for main window");

    try {
      builder.set_translation_domain (Config.GETTEXT_PACKAGE);
      builder.add_from_file (filename);
      builder.connect_signals (this);

      set_default_icon_from_file (get_ui_path ("pixmap/roxen-logo.svg"));
    }
    catch (GLib.Error e) {
      error ("GUI load error: %s", e.message);
    }


    main_vbox       = g ("main_vbox")            as Gtk.VBox;
    sw_files        = g ("sw_files")             as Gtk.ScrolledWindow;
    cb_notify       = g ("cb_notify")            as Gtk.CheckButton;
    cb_minimize     = g ("cb_minimize")          as Gtk.CheckButton;
    cb_logging      = g ("cb_logging")           as Gtk.CheckButton;
    cb_allow_any_cert = g ("cb_allow_any_cert")  as Gtk.CheckButton;
    btn_edit_file   = g ("btn_edit_file")        as Gtk.Button;
    btn_finish_file = g ("btn_finish_file")      as Gtk.Button;
    btn_finish_all  = g ("btn_finish_all")       as Gtk.Button;
    btn_edit_app    = g ("btn_edit_app")         as Gtk.Button;
    btn_add_app     = g ("btn_add_app")          as Gtk.Button;
    btn_remove_app  = g ("btn_remove_app")       as Gtk.Button;
    btn_clear_log   = g ("btn_clear_log")        as Gtk.Button;
    ctx_menu        = g ("tv_files_rclick_menu") as Gtk.Menu;
    tv_files        = g ("tv_files")             as Gtk.TreeView;
    ls_files        = g ("ls_files")             as Gtk.ListStore;
    tv_apps         = g ("tv_apps")              as Gtk.TreeView;
    ls_apps         = g ("ls_apps")              as Gtk.ListStore;
    statusbar       = g ("statusbar1")           as Gtk.Statusbar;
    fcb_logfile     = g ("fcb_logfile")          as Gtk.FileChooserButton;
    logview         = g ("logview")              as Gtk.TextView;
    sp_timeout      = g ("sp_http_query_timeout") as Gtk.SpinButton;

    if (App.is_kde) {
      try {
        string rlogo = get_ui_path ("pixmap/roxen-logo.png");
        set_icon_from_file (rlogo);
      }
      catch (GLib.Error e) {
        warning ("Unable to set icon: %s", e.message);
      }
    }

    if (App.winprops.width > 0 && App.winprops.height > 0)
      set_default_size (App.winprops.width, App.winprops.height);
    else
      set_default_size (WIN_WIDTH, WIN_HEIGHT);

    if (App.winprops.x > 0 || App.winprops.y > 0)
      move (App.winprops.x, App.winprops.y);

    // Window moved/resized
    configure_event.connect ((widget, event) => {
      // Save new window properties
      if (event.type == Gdk.EventType.CONFIGURE && (
          event.width  != App.winprops.width  ||
          event.height != App.winprops.height ||
          event.x      != App.winprops.x      ||
          event.y      != App.winprops.y) && (event.x > -1 && event.y > -1))
      {
        save_window_properties (event.width, event.height, event.x, event.y);
        return false;
      }
      return false;
    });

    delete_event.connect (() => {
      destroy();
      return true;
    });

    // Window minimized
    window_state_event.connect ((wnd, event) => {
      Gdk.WindowState ico = Gdk.WindowState.ICONIFIED;
      Gdk.WindowState max = Gdk.WindowState.MAXIMIZED;

      if (App.do_minimize && event.changed_mask == ico && (
          event.new_window_state == ico ||
          event.new_window_state == (ico | max)))
      {
        //Main.tray.get_icon ().activate ();
      }
      return true;
    });

    // Notifications check button
    cb_notify.active = App.do_notifications;
    cb_notify.toggled.connect (on_cb_notify_toggled);

    // Minimize to tray check button
    cb_minimize.active = App.do_minimize;
    cb_minimize.toggled.connect (on_cb_minimize_toggled);

    // HTTP query timeout
    if (App.do_debug)
      message ("HTTP query timeout: %d", App.query_timeout);

    sp_timeout.adjustment.value = App.query_timeout;
    sp_timeout.adjustment.value_changed.connect (() => {
      if (App.do_debug)
        message ("HTTP query timeout changed: %d", (int) sp_timeout.value);

      App.query_timeout = (int) sp_timeout.value;
    });

    // Enable logging check button
    cb_logging.active = App.do_logging;
    cb_logging.toggled.connect (() => {
      App.do_logging = !App.do_logging;
    });

    cb_allow_any_cert.active = App.allow_all_certs;
    cb_allow_any_cert.toggled.connect (() => {
      App.allow_all_certs = !App.allow_all_certs;
    });

    // Clear log button
    btn_clear_log.sensitive = cb_logging.active;
    btn_clear_log.clicked.connect (() => {
      logger.truncate ();
      logview.buffer.text = "";
      log_message (_("Log file truncated"));
    });

    var filter = new Gtk.FileFilter ();
    filter.add_pattern ("*.log");

    // File choose button
    fcb_logfile.sensitive = cb_logging.active;
    fcb_logfile.filter = filter;
    fcb_logfile.set_filename (logger == null ? App.logfile : logger.path);

    // Log view
    logview.sensitive = cb_logging.active;
    load_logfile ();

    //
    // Treeviews
    //

    // Files treeview and liststore

    ls_files = new Gtk.ListStore (TVFileCols.N_COLS,
                                  typeof (string), typeof (string),
                                  typeof (string), typeof (LauncherFile));
    tv_files.set_model (ls_files);

    string[] cols = { _("File"), _("Status"), _("Last upload") };

    for (ulong i = 0; i < cols.length; i++) {
      var ct = new Gtk.CellRendererText ();
      var cl = new Gtk.TreeViewColumn.with_attributes (cols[i], ct, "text",
                                                       i, null);
      cl.resizable = true;

      if (i == 0) {
        cl.sizing = Gtk.TreeViewColumnSizing.FIXED;
        cl.fixed_width = 420;
      }

      cl.sort_column_id = (int) i;
      tv_files.insert_column (cl, -1);
    }

    foreach (LauncherFile lf in LauncherFile.files) {
      Gtk.TreeIter iter;
      ls_files.prepend (out iter);

      string last_upload = _("Not uploaded");

      if (lf.last_upload != null)
        last_upload = lf.last_upload.format (DATE_FORMAT);

      ls_files.set (iter,
                    TVFileCols.URI, lf.get_uri (),
                    TVFileCols.STATUS, lf.status_as_string (),
                    TVFileCols.LAST_UPLOAD, last_upload,
                    TVFileCols.LAUNCHERFILE, lf,
                    -1);
    }

    if (LauncherFile.files.length () > 0)
      btn_finish_all.sensitive = true;

    set_file_count ();

    // Application treeview
    ls_apps = new Gtk.ListStore (TVCtCols.N_COLS,
                                 typeof (string),
                                 typeof (Gdk.Pixbuf),
                                 typeof (string),
                                 typeof (ContentType));

    tv_apps.set_model (ls_apps);

    tv_apps.insert_column (get_ct_col (_("Content type")), -1);
    tv_apps.insert_column (get_ct_col (_("Application"), true), -1);

    foreach (ContentType ct in ContentType.content_types)
      append_ct (ct);

    //
    // Buttons, treeview events and such
    //

    tv_files.row_activated.connect (on_tv_files_activated);
    tv_files.get_selection ().changed.connect (on_tv_files_selection_changed);
    tv_files.key_release_event.connect (on_tv_files_key_release_event);
    tv_files.button_press_event.connect (on_ctx_popup_menu);

    btn_edit_file.clicked.connect (on_btn_edit_file_clicked);
    btn_finish_file.clicked.connect (on_btn_finish_file_clicked);
    btn_finish_all.clicked.connect (on_btn_finish_all_clicked);

    tv_apps.row_activated.connect (on_tv_apps_activated);
    tv_apps.get_selection ().changed.connect (on_tv_apps_selection_changed);
    btn_add_app.clicked.connect (() => { ct_new (null); });

    btn_edit_app.clicked.connect (on_btn_edit_ct_clicked);
    btn_remove_app.clicked.connect (on_btn_remove_app_clicked);

    tv_apps.key_release_event.connect (on_tv_ct_key_release_event);

    // Quit item in menu
    Gtk.ImageMenuItem imq = ((Gtk.ImageMenuItem) g ("im_quit"));
    imq.activate.connect (on_window_destroy);
    // About item in menu
    Gtk.ImageMenuItem ima = ((Gtk.ImageMenuItem) g ("im_about"));
    ima.activate.connect (on_about);

    // Right click in file list, view file in Sitebuilder
    ((Gtk.MenuItem) g ("sb_view")).activate.connect (() => {
      Gtk.TreeModel model;
      Gtk.TreeIter iter;

      LauncherFile lf = get_selected_file (out model, out iter);

      if (lf != null) {
        string uri = lf.get_sb_uri ();
        string cmd = "xdg-open '" + uri.escape ("") + "'";

        try { Process.spawn_command_line_async (cmd); }
        catch (GLib.Error e) {
          log_error ("Unable to open file %s: %s".printf(uri, e.message));
          warning ("Unable to open file %s: %s", uri, e.message);
        }
      }
    });

    // Right click in file list, view directory in Sitebuilder
    ((Gtk.MenuItem) g ("sb_view_dir")).activate.connect (() => {
      Gtk.TreeModel model;
      Gtk.TreeIter iter;
      LauncherFile lf = get_selected_file (out model, out iter);

      if (lf != null) {
        string uri = Path.get_dirname (lf.get_sb_uri ());
        string cmd = "xdg-open '" + uri.escape ("") + "'";

        try { Process.spawn_command_line_async (cmd); }
        catch (GLib.Error e) {
          log_error ("Unable to open sb-directory %s: %s".printf(uri, e.message));
          warning ("Unable to open sb-directory %s: %s", uri, e.message);
        }
      }
    });

    Gtk.MenuItem md = (Gtk.MenuItem) g ("ctx_menu_delete");
    Gtk.MenuItem me = (Gtk.MenuItem) g ("ctx_menu_edit");
    me.activate.connect (on_btn_edit_file_clicked);
    md.activate.connect (on_ctx_popup_menu_delete);

    //tray = new Tray ();
    //tray.hookup ();

    destroy.connect (on_window_destroy);
    add (main_vbox);

    return true;
  }

  /**
   * Returns object //w// from the builder object
   *
   * @param w
   */
  GLib.Object g (string w)
  {
    return builder.get_object (w);
  }

  // Keeps track of the next column number in content type/application
  // treeview
  int ct_col_pos = 0;

  /**
   * Creates a treeview column for the content type/application treeview
   *
   * @param title
   * @param with_icon
   *  If true an extra cell renderer for an icon will be added.
   */
  Gtk.TreeViewColumn get_ct_col (string title, bool with_icon=false)
  {
    var col = new Gtk.TreeViewColumn ();
    col.title = title;
    col.expand = true;
    col.resizable = true;

    if (with_icon) {
      var crp = new Gtk.CellRendererPixbuf ();
      col.pack_start (crp, false);
      col.add_attribute (crp, "pixbuf", ct_col_pos++);
    }

    col.sort_column_id = ct_col_pos;

    var crt = new Gtk.CellRendererText ();
    col.pack_start (crt, false);
    col.add_attribute (crt, "text", ct_col_pos++);

    return col;
  }

  /**
   * Append content type to treeview
   *
   * @param ct
   */
  void append_ct (ContentType ct)
  {
    Gtk.TreeIter iter;
    ls_apps.append (out iter);
    ls_apps.set (iter,
                 TVCtCols.MIMETYPE,     ct.mimetype,
                 TVCtCols.ICON,         ct.editor.pixbuf,
                 TVCtCols.EDITOR,       ct.editor.name,
                 TVCtCols.CONTENT_TYPE, ct,
                 -1);
  }

  /**
   * Callback for when the main window is destroyed. Quits the application
   */
  public void on_window_destroy ()
  {
    destroy ();
  }

  /**
   * Callback for enabling/disabling notifications
   *
   * @param cb
   */
  public void on_cb_notify_toggled (Object cb)
  {
    if (App.do_debug)
      message ("notify toggled");

    App.do_notifications = !App.do_notifications;
  }

  /**
   * Callback for enabling/disabling minimize to tray
   *
   * @param cb
   */
  public void on_cb_minimize_toggled (Object cb)
  {
    if (App.do_debug)
      message ("notify toggled");

    App.do_minimize = !App.do_minimize;
  }

  /**
   * Callback for the edit application button
   */
  void on_btn_edit_ct_clicked ()
  {
    ct_edit ();
  }

  /**
   * Callback for the remove application button
   */
  void on_btn_remove_app_clicked ()
  {
    remove_ct ();
  }

  /**
   * Callback for the edit file button
   */
  void on_btn_edit_file_clicked ()
  {
    begin_edit_file ();
  }

  /**
   * Callback for the finish file button
   */
  void on_btn_finish_file_clicked ()
  {
    finish_file ();
  }

  /**
   * Callback for the finish alla files button
   */
  void on_btn_finish_all_clicked ()
  {
    finish_all_files ();
  }

  /**
   * Callback for when the apps tree view selection changes
   */
  void on_tv_apps_selection_changed ()
  {
    set_app_buttons_sensitivity ();
  }

  /**
   * Callback for when the selection in the tree view of files is changed
   */
  void on_tv_files_selection_changed ()
  {
    set_buttons_sensitivity ();
  }

  /**
   * Callback for when a file in the treeview is activated (double clicked,
   * enter pressed...). This launches the editor associated with the file.
   *
   * @param path
   * @param col
   */
  void on_tv_files_activated (Gtk.TreePath path, Gtk.TreeViewColumn col)
  {
    begin_edit_file ();
  }

  /**
   * Callback for when an content type in the treeview is activated (double
   * clicked, enter is pressed...).
   *
   * @param path
   * @param col
   */
  void on_tv_apps_activated (Gtk.TreePath path, Gtk.TreeViewColumn col)
  {
    ct_edit ();
  }

  /**
   * Callback for when a key is pressed and the files treeview is active
   *
   * @param source
   * @param key
   */
  bool on_tv_files_key_release_event (Gtk.Widget source, Gdk.EventKey key)
  {
    if (LauncherFile.files.length () > 0) {
      string keyname = Gdk.keyval_name (key.keyval).down ();

      if (keyname == "delete") {
        Gtk.TreeModel model;
        Gtk.TreeIter iter;

        if (get_selected_file (out model, out iter) == null)
          return false;

        if (Alert.confirm (this, _("Do you want to delete the selected file?"))) {
          finish_file ();
          return true;
        }
      }
      else if (keyname == "menu") {
        show_ctx_menu (3, 0);
      }
    }

    return false;
  }

  /**
   * Callback for right click delete
   */
  void on_ctx_popup_menu_delete ()
  {
    Gtk.TreeModel model;
    Gtk.TreeIter iter;

    if (get_selected_file (out model, out iter) == null)
      return;

    if (Alert.confirm (this, _("Do you want to delete the selected file?"))) {
      finish_file ();
      return;
    }

    return;
  }

  /**
   * Callback for when a key is pressed and the applications treeview is
   * active
   *
   * @param source
   * @param key
   */
  bool on_tv_ct_key_release_event (Gtk.Widget source, Gdk.EventKey key)
  {
    if (ContentType.content_types.length () > 0 &&
        Gdk.keyval_name (key.keyval).down () == "delete")
    {
      Gtk.TreeModel model;
      Gtk.TreeIter iter;

      if (get_selected_ct (out model, out iter) == null)
        return false;

      var msg = _("Do you want to delete the selected content type?");

      if (Alert.confirm (this, msg)) {
        remove_ct ();
        return true;
      }
    }

    return false;
  }

  /**
   * Callback for right click in file treeview
   *
   * @param w
   * @param e
   */
  public bool on_ctx_popup_menu (Gtk.Widget w, Gdk.EventButton e)
  {
    if (e.button == 3 && e.type == Gdk.EventType.BUTTON_PRESS)
      show_ctx_menu (e.button, e.time);

    return false;
  }

  /**
   * Callback for the about menu item
   */
  void on_about ()
  {
    var a = new About ();
    a = null;
  }

  // Api

  /**
   * Add a launcher file to the treeview
   *
   * @param lf
   */
  public void add_launcher_file (LauncherFile lf)
  {
    LauncherFile.add_file (lf);
    Gtk.TreeIter iter;
    ls_files.prepend (out iter);

    string last_upload = _("Not uploaded");

    if (lf.status == 0)
      last_upload = lf.last_upload.to_string ();

    ls_files.set (iter,
                  TVFileCols.URI,          lf.get_uri (),
                  TVFileCols.STATUS,       lf.status_as_string (),
                  TVFileCols.LAST_UPLOAD,  last_upload,
                  TVFileCols.LAUNCHERFILE, lf,
                  -1);

    set_file_selection (lf);
    set_file_count ();
  }

  /**
   * Popup the context menu in the file treeview
   *
   * @param button
   * @param time
   */
  void show_ctx_menu (uint button, uint32 time)
  {
    Gtk.TreeModel model;
    Gtk.TreeIter iter;

    LauncherFile f = get_selected_file (out model, out iter);

    if (f != null)
      ctx_menu.popup (null, null, null, button, time);
  }

  /**
   * Removes the selected application from the list
   */
  void remove_ct ()
  {
    Gtk.TreeModel model;
    Gtk.TreeIter iter;

    ContentType app = get_selected_ct (out model, out iter);

    if (app != null) {
      foreach (LauncherFile lf in LauncherFile.files) {
        if (lf.application != null && lf.application.mimetype == app.mimetype)
          lf.unset_application ();
      }

      ContentType.remove_content_type (app);
      ls_apps.remove (iter);
    }
  }

  /**
   * Downloads the currently selected file and launches the corresponding
   * editor.
   */
  void begin_edit_file ()
  {
    Gtk.TreeModel a;
    Gtk.TreeIter b;
    var lf = get_selected_file (out a, out b);

    if (lf != null)
      lf.download.begin ();
  }

  /**
   * Returns the currently selected file in the files tree view
   *
   * @return
   *  The LauncherFile object of the selected file
   */
  LauncherFile? get_selected_file (out Gtk.TreeModel _model,
                                   out Gtk.TreeIter _iter)
  {
    Gtk.TreeSelection sel = tv_files.get_selection ();
    Gtk.TreeIter iter;
    Gtk.TreeModel model;

    _model = null;
    _iter = { 0, null, null, null };

    bool has_sel = sel.get_selected (out model, out iter);

    if (!has_sel) return null;

    LauncherFile lf = null;
    model.get (iter, TVFileCols.LAUNCHERFILE, out lf, -1);

    if (lf == null) return null;

    _model = model;
    _iter = iter;

    return lf;
  }


  /**
   * Returns the currently selected content type if any.
   *
   * @param _model
   * @param _iter
   *
   * @return
   *  The ContentType object or null
   */
  ContentType? get_selected_ct (out Gtk.TreeModel _model,
                                out Gtk.TreeIter _iter)
  {
    Gtk.TreeSelection sel = tv_apps.get_selection ();
    Gtk.TreeIter iter;
    Gtk.TreeModel model;

    _model = null;
    _iter = { 0, null, null, null };

    bool has_sel = sel.get_selected (out model, out iter);

    if (!has_sel)
      return null;

    ContentType ct = null;
    model.get (iter, TVCtCols.CONTENT_TYPE, out ct, -1);

    if (ct == null)
      return null;

    _model = model;
    _iter = iter;

    return ct;
  }

  /**
   * Toggle enable notifications.
   * This is also called from the check menu item in tray.vala
   */
  public void toggle_notifications (int istate=2)
  {
    bool state = istate == 2 ? cb_notify.active : (bool) istate;
    cb_notify.set_active (state);

    App.do_notifications = state;
  }

  /**
   * Toggle minimize to tray on window close button.
   * This is also called from the check menu item in tray.vala
   */
  public void toggle_minimize_to_tray (int istate=2)
  {
    bool state = istate == 2 ? cb_minimize.active : (bool) istate;
    cb_minimize.set_active (state);
    //min_to_tray = state;

    App.do_minimize = state;
  }

  /**
   * Toggle enable logging
   * This is also called from the check menu item in tray.vala
   */
  public void toggle_enable_logging (int istate=2)
  {
    bool state = istate == 2 ? cb_logging.active : (bool) istate;
    cb_logging.set_active (state);

    // In roxenlauncher.vala
    App.do_logging = state;

    btn_clear_log.sensitive = state;
    fcb_logfile.sensitive = state;
    logview.sensitive = state;
  }

  /**
   * Show the dialog for adding a new content type
   *
   * @param ct
   */
  public ContentType? ct_new (string? ct)
  {
    if (ContentType.get_by_ct (ct) != null)
      return null;

    var cf = new ContentTypeForm (_("Add content type"));

    if (cf.run (null, ct) == Gtk.ResponseType.OK) {
      string nct = cf.content_type;
      Editor ed = cf.editor;
      Editor ex;

      if ((ex = Editor.get_by_name (ed.name)) != null)
        ed = ex;
      else
        Editor.add_editor (ed);

      ContentType cto = new ContentType (nct, ed);

      if (ContentType.add_content_type (cto)) {
        if (App.do_debug) {
          message ("Content type added: %s (%s, %s, %s)",
                   nct, ed.name, ed.command, ed.icon);
        }

        append_ct (cto);
      }

      cf = null;
      return cto;
    }

    cf = null;
    return null;
  }

  /**
   * Show the dialog for editing a content type
   *
   * @param ct
   */
  public void ct_edit ()
  {
    if (App.do_debug)
      message ("Launching Content Type Form");

    var cf = new ContentTypeForm (_("Edit content type"));

    if (App.do_debug)
      message ("Content Type Form initialized");

    Gtk.TreeModel model;
    Gtk.TreeIter iter;
    ContentType ct = get_selected_ct (out model, out iter);

    if (ct != null && cf.run (ct) == Gtk.ResponseType.OK) {
      if (cf.content_type != ct.mimetype &&
          (ContentType.get_by_ct (cf.content_type) != null))
      {
        if (App.do_debug)
          message ("Content type %s already exist", cf.content_type);

        return;
      }

      ct.mimetype = cf.content_type;

      if (Editor.get_by_name (cf.editor.name) == null) {
        var ed = new Editor (cf.editor.name, cf.editor.command, cf.editor.icon);
        Editor.add_editor (ed);
        ct.editor = ed;
      }
      else
        ct.editor = cf.editor;

      ls_apps.set (iter,
                   TVCtCols.MIMETYPE, cf.content_type,
                   TVCtCols.ICON,     ct.editor.pixbuf,
                   TVCtCols.EDITOR,   ct.editor.name);

      conf.set_strv ("content-types", ContentType.to_array ());
    }
  }

  /**
   * Set the file status in the treeview
   */
  public void set_file_status (LauncherFile lf, string status)
  {
    ls_files.foreach ((model, path, iter) => {
      Value v;
      model.get_value (iter, TVFileCols.LAUNCHERFILE, out v);
      LauncherFile f = (LauncherFile) v;

      if (f != null && lf.id == f.id) {
        ls_files.set (iter, 1, status);

        if (f.last_upload != null) {
          ls_files.set (iter, TVFileCols.LAST_UPLOAD,
                              f.last_upload.format (DATE_FORMAT));
        }

        return true;
      }

      v.unset ();
      return false;
    });
  }

  /**
   * Selects the launcher file lf in the treeview
   *
   * @param lf
   */
  public void set_file_selection (LauncherFile lf)
  {
    ls_files.foreach ((model, path, iter) => {
      Value v;
      model.get_value (iter, 3, out v);
      LauncherFile f = (LauncherFile) v;

      if (f != null && f.id == lf.id) {
        tv_files.get_selection ().select_path (path);
        return true;
      }

      v.unset ();
      return false;
    });
  }

  /**
   * Displays a notification if wanted
   *
   * @param summary
   * @param text
   */
  public void show_notification (LauncherFile.NotifyType type,
                                 string summary, string text)
  {
    if (cb_notify.active) {

      if (App.do_debug)
        message ("Show notification: %s".printf (summary));

      string icon = null;

      switch (type)
      {
        case LauncherFile.NotifyType.UP:
          //icon = Gtk.Stock.GO_UP;
          icon = "go-up";
          break;

        case LauncherFile.NotifyType.DOWN:
          //icon = Gtk.Stock.GO_DOWN;
          icon = "go-down";
          break;

        case LauncherFile.NotifyType.ERROR:
          //icon = Gtk.Stock.DIALOG_ERROR;
          icon = "dialog-error";
          break;

        default:
          break;
      }

      if (_nf == null)
        _nf = new Notify.Notification (summary, text, icon);
      else
        _nf.update (summary, text, icon);

      // FIXME: This just simply doesn't work!
      _nf.set_timeout (2000);
      try { _nf.show (); }
      catch (GLib.Error e) {
        log_error ("libnotify error: %s".printf(e.message));
        warning ("libnotify error: %s", e.message);
      }
    }
  } private Notify.Notification _nf;

  /**
   * Handles sensitivity of the app related buttons
   */
  void set_app_buttons_sensitivity ()
  {
    Gtk.TreeSelection sel = tv_apps.get_selection ();
    Gtk.TreeIter iter;
    Gtk.TreeModel model;

    bool is_active = sel.get_selected (out model, out iter);

    btn_edit_app.sensitive = is_active;
    btn_remove_app.sensitive = is_active;
  }

  /**
   * Handles the sensitivity of the files related buttons
   */
  void set_buttons_sensitivity ()
  {
    Gtk.TreeSelection sel = tv_files.get_selection ();
    Gtk.TreeIter iter;
    Gtk.TreeModel model;

    bool is_active = sel.get_selected (out model, out iter);

    btn_edit_file.sensitive = is_active;
    btn_finish_file.sensitive = is_active;
    btn_finish_all.sensitive = LauncherFile.files.length () > 0;
  }

  /**
   * Removes the selected files from all lists and from disk
   */
  void finish_file ()
  {
    Gtk.TreeModel model;
    Gtk.TreeIter iter;
    LauncherFile file = get_selected_file (out model, out iter);

    if (file != null && file.delete ()) {
      ls_files.remove (iter);
      LauncherFile.remove_file (file);
    }

    set_file_count ();
    set_buttons_sensitivity ();
  }

  /**
   * Finish all files
   */
  public void finish_all_files ()
  {
    ls_files.clear ();

    foreach (LauncherFile lf in LauncherFile.files)
      lf.delete ();

    LauncherFile.clear_files ();
    set_buttons_sensitivity ();
    set_file_count ();
  }

  /**
   * Updated the statusbar with the current number of files
   */
  void set_file_count ()
  {
    string m = "";
    uint num = LauncherFile.files.length ();

    if (num == 0)
      m = _("No files");
    else if (num == 1)
      m = _("One file");
    else
      m = _("%d active files").printf (num);

    set_status ("# " + m);
  }

  /**
   * Set the status text
   *
   * @param text
   */
  void set_status (string text="")
  {
    statusbar.push (0, text);
  }

  /**
   * Load log file into text view
   */
  public void load_logfile ()
  {
    if (App.do_logging) {
      logview.buffer.text = "";
      update_logview (logger.get_content ());
    }
  }

  /**
   * Update the log text view with //text//
   *
   * @param text
   */
  public void update_logview (string text)
  {
    if (App.do_logging) {
      Gtk.TextBuffer buf = logview.buffer;
      Gtk.TextMark mark;
      Gtk.TextIter iter;

      buf.get_end_iter (out iter);
      buf.insert (ref iter, text, -1);
      buf.get_end_iter (out iter);
      mark = buf.get_insert ();
      buf.place_cursor (iter);
      logview.scroll_to_mark (mark, 0.0, true, 0.0, 1.0);
    }
  }
}

class Roxenlauncher.About : GLib.Object
{
  construct
  {
    Gtk.Builder builder = new Gtk.Builder ();
    string filename = get_ui_path (MAIN_UI_FILENAME);

    if (filename == null)
      error ("Unable to load GUI for about dialog");

    try {
      builder.set_translation_domain (Config.GETTEXT_PACKAGE);
      builder.add_from_file (filename);
    }
    catch (GLib.Error e) {
      error ("GUI load error: %s", e.message);
    }

    var d = (Gtk.AboutDialog) builder.get_object ("aboutdialog");
    string about_logo = get_ui_path ("pixmap/roxen-logo.png");

    if (about_logo != null) {
      try {
        d.logo = new Gdk.Pixbuf.from_file (about_logo);
      }
      catch (GLib.Error e) {
        warning ("Unable to set logo for about dialog: %s", e.message);
      }
    }

    d.set_program_name (_("Roxen™ Application Launcher"));
    d.set_version (Config.VERSION);

    d.run ();
    d.destroy ();
    d = null;
    builder = null;
  }
}
