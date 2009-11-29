using GLib;
using Gtk;
using Roxenlauncher;

namespace Roxenlauncher
{
  public class ApplicationForm : GLib.Object
  {
    Gtk.Builder builder;
    
    Gtk.Dialog dialog;
    
    Gtk.Entry tf_content_type;
    Gtk.Entry tf_editor_name;
    Gtk.Entry tf_editor_cmd;
    Gtk.Entry tf_editor_args;
    
    Gtk.Button btn_ok;
    Gtk.Button btn_cancel;
    Gtk.Button btn_browse;
    
    public bool response { get; private set; default = false; } 

    private string ct = "";
    public string content_type {
      get { return ct; }
      set { ct = value; }
    }
    
    private string name = "";
    public string editor_name {
      get { return name; }
      set { name = value; }
    }
    
    private string cmd = "";
    public string editor_command {
      get { return cmd; }
      set { cmd = value; }
    }

    private string args = "";
    public string editor_arguments {
      get { return args; }
      set { args = value; }
    }

    public void run()
    {
      builder = new Gtk.Builder();
      bool gui_loaded = false;
      string[] ui_paths = App.UI_PATH.split(":", 8);

      foreach (string path in ui_paths) {
        string filename = path + "/" + App.EDITOR_UI_FILENAME;
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

      //builder.connect_signals(this);

      dialog = (Gtk.Dialog) builder.get_object("editor");

      tf_content_type = (Gtk.Entry) builder.get_object("tf_content_type");
      tf_editor_name = (Gtk.Entry) builder.get_object("tf_editor_name");
      tf_editor_cmd = (Gtk.Entry) builder.get_object("tf_editor_cmd");
      tf_editor_args = (Gtk.Entry) builder.get_object("tf_editor_args");
      
      tf_content_type.text = ct;
      tf_editor_name.text  = name;
      tf_editor_cmd.text   = cmd;
      tf_editor_args.text  = args;

      tf_content_type.changed.connect(on_tf_changed);
      tf_editor_name.changed.connect(on_tf_changed);
      tf_editor_cmd.changed.connect(on_tf_changed);
      tf_editor_args.changed.connect(on_tf_changed);

      btn_ok     = (Gtk.Button) builder.get_object("btn_ok");
      btn_cancel = (Gtk.Button) builder.get_object("btn_cancel");
      btn_browse = (Gtk.Button) builder.get_object("btn_browse");

      btn_ok.sensitive = false;

      btn_cancel.clicked.connect(on_btn_cancel_clicked);
      btn_ok.clicked.connect(on_btn_ok_clicked);
      dialog.destroy.connect(on_quit);
      
      
      btn_browse.clicked.connect((() => {
        var fd = new FileDialog();
        var res = fd.run();

        if (res == ResponseType.ACCEPT) {
          tf_editor_cmd.text = fd.get_filename();
          if (tf_editor_name.text == "") {
            string[] s = tf_editor_cmd.text.split("/");
            var n = s[s.length-1];
            tf_editor_name.text = n;
          }
        }
        fd.destroy();
      }));

      dialog.run();
      dialog.destroy();
    }

    private void on_tf_changed(Gtk.Editable src)
    {
      int ok = 0;
      if (tf_content_type.text.contains("/"))
        ok++;
      if (tf_editor_name.text.length > 0)
        ok++;
      if (tf_editor_cmd.text.length > 0)
        ok++;
      btn_ok.sensitive = ok > 2;
    }

    private void on_btn_cancel_clicked(Gtk.Button src)
    {
      message("Cancel was clicked");
      response = false;
    }
    
    private void on_btn_ok_clicked(Gtk.Button src)
    {
      message("Ok button clicked");
      response = true;
      
      ct = tf_content_type.text;
      name = tf_editor_name.text;
      cmd = tf_editor_cmd.text;
      args = tf_editor_args.text;
    }

    void on_quit()
    {
      message("Destroy dialog");
    }
  }
  
  public class FileDialog : FileChooserDialog
  {
    private string last_folder;
    
    public FileDialog()
    {
      last_folder = get_last_folder();
      title = "Select application...";
      action = FileChooserAction.OPEN;
      
      add_button(STOCK_CANCEL, ResponseType.CANCEL);
      add_button(STOCK_OPEN, ResponseType.ACCEPT);
      set_default_response(ResponseType.ACCEPT);
      set_current_folder(last_folder);
      
      this.destroy.connect(() => { destroy(); });
    }
    
    public override void response(int type)
    {
      if (type == ResponseType.ACCEPT) {
        set_last_folder(get_current_folder());
        message("OK: %s", get_filename());
      }
    }
  }
}
