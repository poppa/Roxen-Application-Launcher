/* -*- Mode: Vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/*
 * mainwindow.vala
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

using Notify;
using Roxenlauncher;
using Poppa;

namespace Roxenlauncher
{
  public class MainWindow : GLib.Object
  {
    Gtk.Builder           builder;
    Gtk.Window            win;
    Gtk.ScrolledWindow    sw_files;
    Gtk.CheckButton       cb_notify;
    Gtk.CheckButton       cb_minimize;
    Gtk.Button            btn_edit_file;
    Gtk.Button            btn_finish_file;
    Gtk.Button            btn_finish_all;
    Gtk.Button            btn_edit_app;
    Gtk.Button            btn_add_app;
    Gtk.Button            btn_remove_app;
    Gtk.TreeView          tv_files;
    Gtk.TreeView          tv_apps;
    Gtk.ListStore         ls_files;
    Gtk.ListStore         ls_apps;
    Gtk.Statusbar         statusbar;
    Gtk.Menu              ctx_menu;

    bool min_to_tray = false;

    /**
     * Init main window
     */
    public void init()
    {
      builder = new Gtk.Builder();
      string filename = get_ui_path(App.MAIN_UI_FILENAME);

      if (filename == null)
        error("Unable to load GUI for main window");
        
      try {
        builder.set_translation_domain(Config.GETTEXT_PACKAGE);
        builder.add_from_file(filename);
      }
      catch (GLib.Error e) {
        error("GUI load error: %s", e.message);
      }

      // Setup widgets
      win             = (Gtk.Window)            gtkobj("mainwindow");
      sw_files        = (Gtk.ScrolledWindow)    gtkobj("sw_files");
      cb_notify       = (Gtk.CheckButton)       gtkobj("cb_notify");
      cb_minimize     = (Gtk.CheckButton)       gtkobj("cb_minimize");
      btn_edit_file   = (Gtk.Button)            gtkobj("btn_edit_file");
      btn_finish_file = (Gtk.Button)            gtkobj("btn_finish_file");
      btn_finish_all  = (Gtk.Button)            gtkobj("btn_finish_all");
      btn_edit_app    = (Gtk.Button)            gtkobj("btn_edit_app");
      btn_add_app     = (Gtk.Button)            gtkobj("btn_add_app");
      btn_remove_app  = (Gtk.Button)            gtkobj("btn_remove_app");
      ctx_menu        = (Gtk.Menu)              gtkobj("tv_files_rclick_menu");

      tv_files        = (Gtk.TreeView)          gtkobj("tv_files");
      ls_files        = (Gtk.ListStore)         gtkobj("ls_files");
      tv_apps         = (Gtk.TreeView)          gtkobj("tv_apps");
      ls_apps         = (Gtk.ListStore)         gtkobj("ls_apps");

      statusbar       = (Gtk.Statusbar)         gtkobj("statusbar1");

      if (is_kde) {
				try {
					string rlogo = get_ui_path("pixmap/roxen-logo.png");
					win.set_icon_from_file(rlogo);
				}
				catch (GLib.Error e) {
					warning("Unable to set icon: %s", e.message);
				}
      }
      
      if (winprops.width > 0 && winprops.height > 0)
        win.set_default_size(winprops.width, winprops.height);

      if (winprops.x > 0 || winprops.y > 0)
        win.move(winprops.x, winprops.y);

      // Signals
      win.configure_event.connect((widget, event) => {
        // Save new window properties
        if (event.type == Gdk.EventType.CONFIGURE && (
            event.width  != winprops.width  ||
            event.height != winprops.height ||
            event.x      != winprops.x      ||
            event.y      != winprops.y) && (event.x > -1 && event.y > -1))
        {
          save_window_properties(event.width, event.height, event.x, event.y);
          return false;
        }
        return false;
      });

      win.delete_event.connect(() => {
        Gtk.main_quit();
        return true;
      });

		  win.window_state_event.connect((wnd, event) => {
		    Gdk.WindowState ico = Gdk.WindowState.ICONIFIED;
		    Gdk.WindowState max = Gdk.WindowState.MAXIMIZED;

		    if (min_to_tray && event.changed_mask == ico && (
				    event.new_window_state == ico ||
				    event.new_window_state == (ico | max)))
		    {
					tray.get_icon().activate();
		    }
		    return true;
		  });

      // Notifications check button
      cb_notify.active = get_enable_notifications();
      cb_notify.toggled.connect(() => { toggle_notifications(); });
      
      // Minimize to tray check button
      cb_minimize.active = min_to_tray = get_minimize_to_tray();
      cb_minimize.toggled.connect(() => { toggle_minimize_to_tray(); });

      btn_edit_file.clicked.connect(on_btn_edit_file_clicked);
      btn_finish_file.clicked.connect(on_btn_finish_file_clicked);
      btn_finish_all.clicked.connect(on_btn_finish_all_clicked);

      // Quit item in menu
      Gtk.ImageMenuItem imq = ((Gtk.ImageMenuItem)gtkobj("im_quit"));
      imq.activate.connect(on_window_destroy);
      // About item in menu
      Gtk.ImageMenuItem ima = ((Gtk.ImageMenuItem)gtkobj("im_about"));
      ima.activate.connect(on_about);

      /* File treeview setup */

      tv_files.row_activated.connect(on_tv_files_activated);
      // Setup treeviews and liststores
      ls_files = new Gtk.ListStore(4, typeof(string), typeof(string),
                                      typeof(string), typeof(LauncherFile));
      tv_files.set_model(ls_files);

      string[] cols = { _("File"), _("Status"), _("Last upload") };

      for (ulong i = 0; i < cols.length; i++) {
        var ct = new Gtk.CellRendererText();
        var cl = new Gtk.TreeViewColumn.with_attributes(cols[i], ct, "text", 
                                                        i, null);
        cl.set_resizable(true);
        cl.set_expand(true);
        tv_files.insert_column(cl, -1);
      }

      var dummy_date = new Poppa.DateTime().to_unixtime();

      foreach (LauncherFile lf in LauncherFile.get_files()) {
        Gtk.TreeIter iter;
        ls_files.prepend(out iter);

        string last_upload = _("Not uploaded");
        if (lf.last_upload.to_unixtime() > dummy_date)
          last_upload = lf.last_upload.format(App.DATE_FORMAT);

        ls_files.set(iter, 0, lf.get_uri(), 1, lf.status_as_string(),
                           2, last_upload, 3, lf, -1);        
      }

      if (LauncherFile.get_files().length() > 0)
        btn_finish_all.sensitive = true;

      set_file_count();

      tv_files.get_selection().changed.connect(on_tv_files_selection_changed);
      tv_files.key_release_event.connect(on_tv_files_key_release_event);
      tv_files.button_press_event.connect(on_ctx_popup_menu);

			// Right click in file list, view file in Sitebuilder
      ((Gtk.MenuItem)gtkobj("sb_view")).activate.connect(() => {
      	Gtk.TreeModel model;
      	Gtk.TreeIter iter;
      	LauncherFile lf = get_selected_file(out model, out iter);
      	if (lf != null) {
      		string uri = lf.get_sb_uri();
      		string cmd = "xdg-open '" + uri.escape("") + "'";
      		try { Process.spawn_command_line_async(cmd); }
	 			  catch (GLib.Error e) {
	 			  	warning("Unable to open file: %s", e.message);
	 			  }
      	}
      });

			// Right click in file list, view directory in Sitebuilder
      ((Gtk.MenuItem)gtkobj("sb_view_dir")).activate.connect(() => {
      	Gtk.TreeModel model;
      	Gtk.TreeIter iter;
      	LauncherFile lf = get_selected_file(out model, out iter);
      	if (lf != null) {
      		string uri = Path.get_dirname(lf.get_sb_uri());
      		string cmd = "xdg-open '" + uri.escape("") + "'";
      		try { Process.spawn_command_line_async(cmd); }
	 			  catch (GLib.Error e) {
	 			  	warning("Unable to open file: %s", e.message);
	 			  }
      	}
      });

      Gtk.MenuItem md = (Gtk.MenuItem)gtkobj("ctx_menu_delete");
      Gtk.MenuItem me = (Gtk.MenuItem)gtkobj("ctx_menu_edit");
      me.activate.connect(on_btn_edit_file_clicked);
      md.activate.connect(on_ctx_popup_menu_delete);

      /* Applications treeview setup */

      ls_apps = new Gtk.ListStore(3, typeof(string), typeof(string),
                                     typeof(Application));
      tv_apps.set_model(ls_apps);

      cols = { _("Content type"), _("Application") };
      for (ulong i = 0; i < cols.length; i++) {
        var ct = new Gtk.CellRendererText();
        var cl = new Gtk.TreeViewColumn.with_attributes(cols[i], ct, "text",
                                                        i, null);
        cl.set_resizable(true);
        tv_apps.insert_column(cl, -1);
      }

      foreach (Application app in Application.get_applications()) {
        Gtk.TreeIter iter;
        ls_apps.append(out iter);
        ls_apps.set(iter, 0, app.mimetype, 1, app.name, 2, app, -1);
      }

      tv_apps.row_activated.connect(on_tv_apps_activated);
      tv_apps.get_selection().changed.connect(on_tv_apps_selection_changed);
      btn_add_app.clicked.connect(() => { editor_dialog_new(""); });
      btn_edit_app.clicked.connect(on_btn_edit_app_clicked);
      btn_remove_app.clicked.connect(on_btn_remove_app_clicked);

      tv_apps.key_release_event.connect(on_tv_apps_key_release_event);
      
      Notify.init(App.NAME);
    }

		/** 
		 * Callback for right click in file treeview
		 *
		 * @param w
		 * @param e
		 */
		public bool on_ctx_popup_menu(Gtk.Widget w, Gdk.EventButton e)
		{
  		if (e.button == 3 && e.type == Gdk.EventType.BUTTON_PRESS) {
        Gtk.TreeModel model;
        Gtk.TreeIter iter;

        LauncherFile f = get_selected_file(out model, out iter);

        if (f != null) {
			    ctx_menu.popup(null, null, null, e.button, e.time);
	 			  return false;
		    }
  		}
  		return false;
		}

    /**
     * Toggle enable notifications.
     * This is also called from the check menu item in tray.vala
     */ 
    public void toggle_notifications(int istate=2)
    {
      bool state = istate == 2 ? cb_notify.active : (bool)istate;
      cb_notify.set_active(state);
      set_enable_notifications(state);
    }
    
    /**
     * Toggle minimize to tray on window close button.
     * This is also called from the check menu item in tray.vala
     */
    public void toggle_minimize_to_tray(int istate=2)
    {
      bool state = istate == 2 ? cb_minimize.active : (bool)istate;
      cb_minimize.set_active(state);
      min_to_tray = state;
      // In application.vala
      set_minimize_to_tray(state);
    }

    /**
     * Popup the dialog for adding an application
     *
     * @param content_type
     * @return
     *  Returns the newly created Application object
     */
    public Application? editor_dialog_new(string content_type)
    {
      var d = new ApplicationForm();
      d.content_type = content_type;
      d.run();
      if (d.response) {
        Application app = new Application(d.editor_name, d.editor_command,
                                          d.content_type, d.editor_arguments);
        if (Application.add_application(app)) {
		      Gtk.TreeIter iter;
		      ls_apps.append(out iter);
		      ls_apps.set(iter, 0, app.mimetype, 1, app.name, 2, app);
		      return app;
		    }
      }

      return null;
    }

    /**
     * Callback for the about menu item
     */
    void on_about()
    {
      var a = new About();
      //a.run();
      a = null;
    }

    /**
     * Returns the GTK main window object
     */
    public Gtk.Window get_window()
    {
      return win;
    }
    
    /**
     * Popup the dialog for editing the selected application
     */
    public void editor_dialog_edit()
    {
      Gtk.TreeModel model;
      Gtk.TreeIter iter;
      Application app = get_selected_application(out model, out iter);
      
      if (app != null) {
        var d = new ApplicationForm();
        d.content_type = app.mimetype;
        d.editor_name = app.name;
        d.editor_command = app.command;
        d.editor_arguments = app.arguments;
        d.run();

        if (d.response) {
        	if (d.content_type != app.mimetype)
        		if (Application.get_for_mimetype(d.content_type) != null)
        			return;

          app.mimetype = d.content_type;
          app.name = d.editor_name;
          app.command = d.editor_command;
          app.arguments = d.editor_arguments;
          Application.save_list();
          ls_apps.set(iter, 0, d.content_type, 1, d.editor_name);
        }
      }
    }

    /**
     * Set the file status in the treeview
     */
    public void set_file_status(LauncherFile lf, string status)
    {
      ls_files.foreach((model, path, iter) => {
        Value v;
        model.get_value(iter, 3, out v);
        LauncherFile f = (LauncherFile)v;
        if (f != null && lf.id == f.id) {
          ls_files.set(iter, 1, status);
          if (f.last_upload.to_unixtime() > (new Poppa.DateTime().to_unixtime()))
            ls_files.set(iter, 2, f.last_upload.format(App.DATE_FORMAT));
          return true;
        }

        v.unset();
        return false;
      });
    }
    
    /**
     * Add a launcher file to the treeview
     *
     * @param lf
     */
    public void add_launcher_file(LauncherFile lf)
    {
#if DEBUG
      message("Add launcher file: %s", lf.get_uri());
#endif
      LauncherFile.add_file(lf);
      Gtk.TreeIter iter;
      ls_files.prepend(out iter);

      string last_upload = "";
      if (lf.status == 0)
        last_upload = lf.last_upload.to_string();

      ls_files.set(iter, 0, lf.get_uri(), 1, lf.status_as_string(),
                         2, last_upload, 3, lf, -1);  
                         
      set_file_selection(lf);
      set_file_count();
    }
    
    /**
     * Selects the launcher file lf in the treeview
     *
     * @param lf
     */
    public void set_file_selection(LauncherFile lf)
    {
      ls_files.foreach((model, path, iter) => {
        Value v;
        model.get_value(iter, 3, out v);
        LauncherFile f = (LauncherFile)v;
        
        if (f != null && f.id == lf.id) {
          tv_files.get_selection().select_path(path);
          return true;
        }

        v.unset();
        return false;
      });
    }

    /**
     * Shortcut for getting a Gtk object from the Glade file
     *
     * @param name
     * @return
     *  The Gtk object
     */
    GLib.Object gtkobj(string name)
    {
      return builder.get_object(name);
    }

    /**
     * Callback for the edit application button
     */
    void on_btn_edit_app_clicked()
    {
      editor_dialog_edit();
    }

    /**
     * Callback for the remove application button
     */
    void on_btn_remove_app_clicked()
    {
      remove_application();
    }
    
    /**
     * Callback for the edit file button
     */
    void on_btn_edit_file_clicked()
    {
      begin_edit_file();
    }
    
    /**
     * Callback for the finish file button
     */
    void on_btn_finish_file_clicked()
    {
      finish_file();
    }

    /**
     * Callback for the finish alla files button
     */
    void on_btn_finish_all_clicked()
    {
      finish_all_files();
    }
    
    /**
     * Callback for when the apps tree view selection changes
     */
    void on_tv_apps_selection_changed()
    {
      set_app_buttons_sensitivity();
    }

    /**
     * Callback for when the selection in the tree view of files is changed
     */
    void on_tv_files_selection_changed()
    {
      set_buttons_sensitivity();
    }

    /**
     * Callback for when a file in the treeview is activated (double clicked,
     * enter i pressed...). This launches the editor associated with the file.
     *
     * @param path
     * @param col
     */
    void on_tv_files_activated(Gtk.TreePath path, Gtk.TreeViewColumn col)
    {
      begin_edit_file();
    }
    
    /**
     * Callback for when an app in the treeview is activated (double clicked,
     * enter is pressed...).
     *
     * @param path
     * @param col
     */
    void on_tv_apps_activated(Gtk.TreePath path, Gtk.TreeViewColumn col)
    {
      Gtk.TreeModel a;
      Gtk.TreeIter b;
      if (get_selected_application(out a, out b) != null)
        editor_dialog_edit();
    }  

    /**
     * Callback for when a key is pressed and the files treeview is active
     *
     * @param source
     * @param key
     */
    bool on_tv_files_key_release_event(Gtk.Widget source, Gdk.EventKey key)
    {
      if (LauncherFile.get_files().length() > 0 &&
          Gdk.keyval_name(key.keyval).down() == "delete")
      {
        Gtk.TreeModel model;
        Gtk.TreeIter iter;

        if (get_selected_file(out model, out iter) == null)
          return false;
        
        if (Alert.confirm(win, _("Do you want to delete the selected file?"))) {
          finish_file();
          return true;
        }
      }

      return false;
    }
    
    /**
     * Callback for right click delete
     */
    void on_ctx_popup_menu_delete()
    {
    	Gtk.TreeModel model;
    	Gtk.TreeIter iter;
    	
    	if (get_selected_file(out model, out iter) == null)
    		return;
    		
    	if (Alert.confirm(win, _("Do you want to delete the selected file?"))) {
        finish_file();
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
    bool on_tv_apps_key_release_event(Gtk.Widget source, Gdk.EventKey key)
    {
      if (Application.get_applications().length() > 0 &&
          Gdk.keyval_name(key.keyval).down() == "delete")
      {
        Gtk.TreeModel model;
        Gtk.TreeIter iter;

        if (get_selected_application(out model, out iter) == null)
          return false;

        var msg = _("Do you want to delete the selected application?");
        if (Alert.confirm(win, msg)) {
          remove_application();
          return true;
        }
      }

      return false;
    }

    /**
     * Callback for when the main window is destroyed. Quits the application
     */ 
    public void on_window_destroy()
    {
      Gtk.main_quit();
    }

    /**
     * Handles sensitivity of the app related buttons
     */
    void set_app_buttons_sensitivity()
    {
      Gtk.TreeSelection sel = tv_apps.get_selection();
      Gtk.TreeIter iter;
      Gtk.TreeModel model;
      
      bool is_active = sel.get_selected(out model, out iter);

      btn_edit_app.sensitive = is_active;
      btn_remove_app.sensitive = is_active;
    }

    /**
     * Handles the sensitivity of the files related buttons
     */
    void set_buttons_sensitivity()
    {
      Gtk.TreeSelection sel = tv_files.get_selection();
      Gtk.TreeIter iter;
      Gtk.TreeModel model;

      bool is_active = sel.get_selected(out model, out iter);

      btn_edit_file.sensitive = is_active;
      btn_finish_file.sensitive = is_active;
      btn_finish_all.sensitive = LauncherFile.get_files().length() > 0;
    }
    
    /**
     * Removes the selected files from all lists and from disk
     */
    void finish_file()
    {
      Gtk.TreeModel model;
      Gtk.TreeIter iter;
      LauncherFile file = get_selected_file(out model, out iter);

      if (file != null && file.delete()) {
        ls_files.remove(iter);
        LauncherFile.remove_file(file);
      }

      set_file_count();
      set_buttons_sensitivity();
    }
    
    /**
     * Finish all files
     */
    public void finish_all_files()
    {
      ls_files.clear();

      foreach (LauncherFile lf in LauncherFile.get_files())
        lf.delete();

      LauncherFile.clear_files();
      set_buttons_sensitivity();
      set_file_count();
    }

    /**
     * Removes the selected application from the list
     */
    void remove_application()
    {
      Gtk.TreeModel model;
      Gtk.TreeIter iter;
      
      Application app = get_selected_application(out model, out iter);
      if (app != null) {
        foreach (LauncherFile lf in LauncherFile.get_files()) {
          if (lf.application != null && lf.application.mimetype == app.mimetype)
            lf.unset_application();
        }
        Application.remove_application(app);
        ls_apps.remove(iter);
      }
    }
    
    /**
     * Downloads the currently selected file and launches the corresponding
     * editor.
     */
    void begin_edit_file()
    {
      Gtk.TreeModel a;
      Gtk.TreeIter b;
      var lf = get_selected_file(out a, out b);

      if (lf != null)
        lf.download();
    }

    /**
     * Returns the currently selected file in the files tree view
     *
     * @return 
     *  The LauncherFile object of the selected file
     */
    LauncherFile? get_selected_file(out Gtk.TreeModel _model, 
                                    out Gtk.TreeIter _iter)
    {
      Gtk.TreeSelection sel = tv_files.get_selection();
      Gtk.TreeIter iter;
      Gtk.TreeModel model;

      bool has_sel = sel.get_selected(out model, out iter);
      
      if (!has_sel)
        return null;

      LauncherFile lf = null;
      model.get(iter, 3, out lf, -1);

      if (lf == null)
        return null;

      _model = model;
      _iter = iter;

      return lf;
    }
    
    /**
     * Returns the currently selected application if any.
     *
     * @param _model
     * @param _iter
     *
     * @return
     *  The application object or null
     */
    Application? get_selected_application(out Gtk.TreeModel _model,
                                          out Gtk.TreeIter _iter)
    {
      Gtk.TreeSelection sel = tv_apps.get_selection();
      Gtk.TreeIter iter;
      Gtk.TreeModel model;
      
      bool has_sel = sel.get_selected(out model, out iter);
      
      if (!has_sel)
        return null;
        
      Application app = null;
      model.get(iter, 2, out app, -1);
      
      if (app == null)
        return null;
      
      _model = model;
      _iter = iter;

      return app;
    }

    /**
     * Updated the statusbar with the current number of files
     */    
    void set_file_count()
    {
      string m = "";
      uint num = LauncherFile.get_files().length();
      
      if (num == 0)
        m = _("No files");
      else if (num == 1)
        m = _("One file");
      else
        m = _("%d active files").printf(num);

      set_status("# " + m);
    }

    /**
     * Set the status text
     *
     * @param text
     */
    void set_status(string text="")
    {
      statusbar.push(0, text);
    }

    /** 
     * Displays a notification if wanted
     *
     * @param summary
     * @param text
     */
    public void show_notification(LauncherFile.NotifyType type,
                                  string summary, string text)
    {
      if (cb_notify.active) {
        string icon = null;
        switch (type)
        {
          case LauncherFile.NotifyType.UP:
            icon = get_ui_path("pixmap/up_48.png");
            break;

          case LauncherFile.NotifyType.DOWN:
            icon = get_ui_path("pixmap/down_48.png");
            break;

          case LauncherFile.NotifyType.ERROR:
            icon = get_ui_path("pixmap/warning_48.png");
            break;

          default:
            break;
        }
				
        var nf = new Notification(summary, text, null);
        // FIXME: This just simply doesn't work!
        nf.set_timeout(4000); 
	      try {
	        nf.set_icon_from_pixbuf(new Gdk.Pixbuf.from_file(icon)); 
	        nf.show(); 
	      }
	      catch (GLib.Error e) {
	        message("libnotify error: %s", e.message);
	      }
	    }
    }
  }

  class About : GLib.Object
  {
    construct 
    {
      Gtk.Builder builder = new Gtk.Builder();
      string filename = get_ui_path(App.MAIN_UI_FILENAME);

      if (filename == null)
        error("Unable to load GUI for about dialog");

      try {
        builder.set_translation_domain(Config.GETTEXT_PACKAGE);
        builder.add_from_file(filename);
      }
      catch (GLib.Error e) {
        error("GUI load error: %s", e.message);
      }
      
      var d = (Gtk.AboutDialog) builder.get_object("aboutdialog");
      string about_logo = get_ui_path("pixmap/roxen-logo.png");
      if (about_logo != null) {
        try {
          d.logo = new Gdk.Pixbuf.from_file(about_logo);
        }
        catch (GLib.Error e) {
          warning("Unable to set logo for about dialog: %s", e.message);
        }
      }

      d.set_program_name(_("Roxen™ Application Launcher"));
      d.set_version(Config.VERSION);

      d.run();
      d.destroy();
      d = null;
      builder = null;
    }
  }
}
