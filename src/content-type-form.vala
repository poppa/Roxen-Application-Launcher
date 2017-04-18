/* -*- Mode: Vala; indent-tabs-mode: s; c-basic-offset: 2; tab-width: 2 -*- */
/* content-type-form.vala
 *
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

using GLib;
using Gtk;

class Roxenlauncher.ContentTypeForm : GLib.Object
{
  Builder          builder;
  Dialog           dialog;
  Entry            tf_content_type;
  Button           btn_app_chooser;
  Button           btn_ok;
  Button           btn_cancel;
  AppChooserButton btn_app_chooser2;

  public Editor? editor { get; private set; default = null; }

  enum PreviousAction {
    NONE,
    LOAD,
    NEW
  }

  PreviousAction prevaction = PreviousAction.NONE;

  string? _content_type;
  public string? content_type {
    get {
      return _content_type;
    }
    private set {
      _content_type = value;
      tf_content_type.text = value;
    }
  }

  public ContentTypeForm (string title)
  {
    builder = new Builder ();

    try {
      builder.set_translation_domain (Config.GETTEXT_PACKAGE);
      builder.add_from_file (get_ui_path ("content-type.ui"));
    }
    catch (GLib.Error e) {
      error (_("Error: %s\n").printf (e.message));
    }

    prevaction = PreviousAction.LOAD;

    dialog           = g ("dialog")           as Dialog;
    tf_content_type  = g ("tf_content_type")  as Entry;
    btn_app_chooser  = g ("btn_app_chooser")  as Button;
    btn_ok           = g ("btn_ok")           as Button;
    btn_cancel       = g ("btn_cancel")       as Button;
    btn_app_chooser2 = g ("btn_app_chooser2") as AppChooserButton;

    btn_ok.sensitive = false;
    tf_content_type.sensitive = true;

    tf_content_type.changed.connect (on_tf_changed);

    btn_app_chooser.clicked.connect (() => {
      AppInfo app = app_chooser (tf_content_type.text);

      if (App.do_debug) message ("AppInfo: %s", app.get_name());

      if (app != null) {
        editor = new Editor (app.get_name (), app.get_commandline (),
                             app.get_icon ().to_string ());

        try {
          prevaction = PreviousAction.NEW;
          var ico = Icon.new_for_string (editor.icon);
          btn_app_chooser2.append_custom_item (editor.name, editor.name, ico);
          btn_app_chooser2.set_active_custom_item (editor.name);
        }
        catch (Error e) {
          log_message (_("Failed adding application to button: %s")
                        .printf (e.message));
        }
      }
    });

    foreach (Editor ed in Editor.editors) {
      try {
        btn_app_chooser2.append_custom_item (ed.name, ed.name,
                                             Icon.new_for_string (ed.icon));
      }
      catch (GLib.Error e) {
        log_warning (_("Error adding application to button: %s")
                      .printf (e.message));
      }
    }

    btn_app_chooser2.show_dialog_item = true;

    btn_app_chooser2.changed.connect (() => {
      if (!(prevaction == PreviousAction.LOAD ||
            prevaction == PreviousAction.NEW))
      {
        string name = get_app_btn_value ();
        editor = Editor.get_by_name (name);
      }

      on_tf_changed (null);
      prevaction = PreviousAction.NONE;
    });
  }

  public int run (ContentType? ct=null, string? cts=null)
  {
    if (ct == null && cts == null) {

    }
    else if (ct == null) {
      content_type = cts;
    }
    else {
      btn_app_chooser2.set_active_custom_item (ct.editor.name);
      tf_content_type.text = ct.mimetype;
      editor = ct.editor;
    }

    prevaction = PreviousAction.NONE;

    btn_ok.sensitive = false;

    int resp = dialog.run ();

    if (resp == Gtk.ResponseType.OK)
      _content_type = tf_content_type.text;

    dialog.destroy ();
    return resp;
  }

  AppInfo? app_chooser (string content_type)
  {
    AppInfo app = null;

    Gtk.AppChooserDialog ac =
      new Gtk.AppChooserDialog.for_content_type (window,
                                                 Gtk.DialogFlags.MODAL,
                                                 content_type);

    if (ac.run () == Gtk.ResponseType.OK)
      app = ac.get_app_info ();

    ac.destroy ();

    return app;
  }

  GLib.Object g (string p)
  {
    return builder.get_object (p);
  }

  string? get_app_btn_value ()
  {
    Gtk.TreeIter iter;

    if (btn_app_chooser2.get_active_iter (out iter)) {
      string v;
      btn_app_chooser2.model.get (iter, 1, out v, -1);
      return v;
    }

    return null;
  }

  void on_tf_changed (Gtk.Editable? src)
  {
    int ok = 0;

    if (tf_content_type.text.contains ("/"))
      ok++;

    if (get_app_btn_value () != null)
      ok++;

    btn_ok.sensitive = ok == 2;
  }
}
