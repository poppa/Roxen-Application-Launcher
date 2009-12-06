using Gee;
using Roxenlauncher;

namespace Roxenlauncher
{
  public class MainWindow : GLib.Object
  {
    Gtk.Builder builder;
    Gtk.Window win;
    Gtk.ScrolledWindow    sw_files;
    Gtk.CheckButton       cb_logging;
    Gtk.FileChooserButton fc_logfile;
    
    Gtk.Button btn_edit_file;
    Gtk.Button btn_finish_file;
    Gtk.Button btn_finish_all;
    
    Gtk.Button btn_edit_app;
    Gtk.Button btn_add_app;
    Gtk.Button btn_remove_app;
    
    Gtk.TreeView tv_files;
    Gtk.TreeView tv_apps;
    
    Gtk.ListStore ls_files;
    Gtk.ListStore ls_apps;
    
    Gtk.Statusbar statusbar;
   
    /**
     * Init main window
     */
    public void init()
    {
      builder = new Gtk.Builder();
      bool gui_loaded = false;
      
      message("UI PATH: %s", App.UI_PATH);
      string[] ui_paths = App.UI_PATH.split(":", 8);

      foreach (string path in ui_paths) {
        string filename = path + "/" + App.MAIN_UI_FILENAME;
        
        if (!filename.has_prefix("/")) {
          filename = "/home/pontus/Vala/roxenlauncher/src/" + filename;
        }
        
        message("UI file name: %s", filename);
        if (FileUtils.test(filename, FileTest.EXISTS)) {
          try {
            builder.set_translation_domain("roxenlauncher");
            builder.add_from_file(filename);
            gui_loaded = true;
          }
          catch (Error e) {
            warning("GUI load error: %s", e.message);
          }
        }
      }

      if (!gui_loaded) {
        error("Unable to load GUI for main window");
      }

      builder.connect_signals(this);

      // Setup widgets
      win             = (Gtk.Window)            gtkobj("mainwindow");
      sw_files        = (Gtk.ScrolledWindow)    gtkobj("sw_files");
      fc_logfile      = (Gtk.FileChooserButton) gtkobj("fc_logfile");
      cb_logging      = (Gtk.CheckButton)       gtkobj("cb_logging");
      btn_edit_file   = (Gtk.Button)            gtkobj("btn_edit_file");
      btn_finish_file = (Gtk.Button)            gtkobj("btn_finish_file");
      btn_finish_all  = (Gtk.Button)            gtkobj("btn_finish_all");
      btn_edit_app    = (Gtk.Button)            gtkobj("btn_edit_app");
      btn_add_app     = (Gtk.Button)            gtkobj("btn_add_app");
      btn_remove_app  = (Gtk.Button)            gtkobj("btn_remove_app");
      
      tv_files        = (Gtk.TreeView)          gtkobj("tv_files");
      ls_files        = (Gtk.ListStore)         gtkobj("ls_files");
      tv_apps         = (Gtk.TreeView)          gtkobj("tv_apps");
      ls_apps         = (Gtk.ListStore)         gtkobj("ls_apps");

      statusbar       = (Gtk.Statusbar)         gtkobj("statusbar1");

      // Signals      
      win.destroy += on_window_destroy;
      cb_logging.toggled += () => { 
        fc_logfile.sensitive = cb_logging.active;
      };
      btn_edit_file.clicked   += on_btn_edit_file_clicked;
      btn_finish_file.clicked += on_btn_finish_file_clicked;
      btn_finish_all.clicked  += on_btn_finish_all_clicked;

      // Quit item in menu
      ((Gtk.ImageMenuItem)gtkobj("im_quit")).activate += on_window_destroy;
      
      /* File treeview setup */
      
      tv_files.row_activated += on_tv_files_activated;
      // Setup treeviews and liststores
      ls_files = new Gtk.ListStore(4, typeof(string), typeof(string),
                                      typeof(string), typeof(LauncherFile));
      tv_files.set_model(ls_files);

      string[] cols = { "File", "Staus", "Last upload" };

      for (ulong i = 0; i < cols.length; i++) {
        var ct = new Gtk.CellRendererText();
        var cl = new Gtk.TreeViewColumn.with_attributes(cols[i], ct, "text", 
                                                        i, null);
        cl.set_resizable(true);
        cl.set_expand(true);
        tv_files.insert_column(cl, -1);
      }
      
      var dummy_date = new DateTime().to_unixtime();

      foreach (LauncherFile lf in LauncherFile.get_files()) {
        Gtk.TreeIter iter;
        ls_files.append(out iter);

        string last_upload = "";
        if (lf.last_upload.to_unixtime() > dummy_date)
          last_upload = lf.last_upload.format(App.DATE_FORMAT);

        ls_files.set(iter, 0, lf.get_uri(), 1, lf.status_as_string(),
                           2, last_upload, 3, lf, -1);        
      }

      if (LauncherFile.get_files().size > 0)
        btn_finish_all.sensitive = true;
        
      set_file_count();
      
      tv_files.get_selection().changed += on_tv_files_selection_changed;
      tv_files.key_release_event.connect(on_tv_files_key_release_event);
      
      /* Applications treeview setup */

      ls_apps = new Gtk.ListStore(3, typeof(string), typeof(string),
                                     typeof(Application));
      tv_apps.set_model(ls_apps);
      
      cols = { "Content type", "Application" };
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

      tv_apps.row_activated           += on_tv_apps_activated;
      tv_apps.get_selection().changed += on_tv_apps_selection_changed;
      btn_add_app.clicked             += () => { editor_dialog_new(""); };
      btn_edit_app.clicked            += on_btn_edit_app_clicked;
      btn_remove_app.clicked          += on_btn_remove_app_clicked;

      tv_apps.key_release_event.connect(on_tv_apps_key_release_event);

      win.show_all();
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
      message("OK");

      var d = new ApplicationForm();
      d.content_type = content_type;
      message("Running dialog...");
      d.run();
      if (d.response) {
        message("Ok, save...");
        Application app = new Application(d.editor_name, d.editor_command,
                                          d.content_type, d.editor_arguments);
                                          
        Application.add_application(app);
        Gtk.TreeIter iter;
        ls_apps.append(out iter);
        ls_apps.set(iter, 0, app.mimetype, 1, app.name, 2, app);
        return app;
      }
      else
        message("Abort...");
      
      return null;
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
          message("Ok update ...");
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
      //message("Set file status");

      ls_files.foreach((model, path, iter) => {
        Value v;
        model.get_value(iter, 3, out v);
        LauncherFile f = (LauncherFile)v;
        if (f != null && lf.id == f.id) {
          ls_files.set(iter, 1, status);
          if (f.last_upload.to_unixtime() > (new DateTime().to_unixtime()))
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
      ls_files.append(out iter);

      string last_upload = "";
      if (lf.status == 0)
        last_upload = lf.last_upload.to_string();

      ls_files.set(iter, 0, lf.get_uri(), 1, lf.status_as_string(),
                         2, last_upload, 3, lf, -1);  
    }

    /**
     * Shortcut for getting a Gtk object fron the Glade file
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
      if (LauncherFile.get_files().size > 0 &&
          Gdk.keyval_name(key.keyval).down() == "delete")
      {
        Gtk.TreeModel model;
        Gtk.TreeIter iter;

        if (get_selected_file(out model, out iter) == null) {
          message("No selected file to delete!");
          return false;
        }
        
        if (Alert.confirm(win, "Do you want to delete the selected file?")) {
          finish_file();
          return true;
        }
      }

      return false;
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
      if (Application.get_applications().size > 0 &&
          Gdk.keyval_name(key.keyval).down() == "delete")
      {
        Gtk.TreeModel model;
        Gtk.TreeIter iter;

        if (get_selected_application(out model, out iter) == null) {
          message("No selected file to delete!");
          return false;
        }
        
        var msg = "Do you want to delete the selected application?";
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
    void on_window_destroy()
    {
      message("Main killed");
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
      btn_finish_all.sensitive = LauncherFile.get_files().size > 0;
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
    void finish_all_files()
    {
      message("Finish all files...");
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
          if (lf.application.mimetype == app.mimetype)
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

      if (lf != null) {
        message("Begin edit file...%s", lf.get_uri());
        //lf.launch_editor();
        lf.download();
      }
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

      if (lf == null) {
        message("No file selected!");
        return null;
      }

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
      
      if (app == null) {
        message("No application selected...!");
        return null;
      }
      
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
      int num = LauncherFile.get_files().size;
      
      if (num == 0)
        m = "No files";
      else if (num == 1)
        m = "One file";
      else
        m = "%ld files".printf(num);

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
  }
}