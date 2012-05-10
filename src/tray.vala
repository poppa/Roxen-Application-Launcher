/* -*- Mode: Vala; indent-tabs-mode: s; c-basic-offset: 2; tab-width: 2 -*- */
/* tray.vala
 * 
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
 * with RAL. If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;

public class Roxenlauncher.Tray : GLib.Object
{
  Gtk.StatusIcon icon;
  Gtk.Menu       popmenu;

  string m_show = _("Click to show the application launcher");
  string m_hide = _("Click to hide the application launcher");
  string t_show = _("Show application launcher");
  string t_hide = _("Hide application launcher");    

  construct {
    try {
      Gdk.Pixbuf logo;
      string ico = get_ui_path ("pixmap/roxen-logo-small.png");
      logo = new Gdk.Pixbuf.from_file (ico);
      icon = new Gtk.StatusIcon.from_pixbuf (logo);
      icon.tooltip_text = m_hide;
      icon.set_visible (false);
    }
    catch (Error e) {
      warning ("Unable to load logo for tray! Can't start panel applet");
    }
  }
  
  public StatusIcon get_icon ()
  {
    return icon;
  }
  
  public void hookup ()
  {
    icon.popup_menu.connect (on_trayicon_popup);
    icon.activate.connect (set_window_visibility);
    icon.set_visible (true);
  }
  
  public void set_blinking (bool val)
  {
    // icon.set_blinking(val);
  }
  
  public void hide_window ()
  {
    set_window_visibility ();
  }
  
  void on_trayicon_popup (uint btn, uint time)
  {
    popmenu = new Gtk.Menu ();
  
    var visible     = window.visible;
    var item_quit   = new ImageMenuItem.from_stock (Stock.QUIT, null);
    var img_hide    = new Image.from_stock (Stock.CLOSE, IconSize.MENU);
    var img_show    = new Image.from_stock (Stock.OPEN, IconSize.MENU);
    var item_toggle = new ImageMenuItem.with_label (visible ? t_hide : t_show);

    if (!App.do_minimize)
      item_toggle.sensitive = false;

    item_toggle.set_image (visible ? img_hide : img_show);

    GLib.List<LauncherFile> lfs = LauncherFile.get_reversed_files ();

    if (lfs.length () == 0) {
      var mi = new Gtk.MenuItem.with_label (_("No active files"));
      mi.sensitive = false;
      popmenu.add (mi);
    }
    else {
      foreach (LauncherFile lf in lfs) {
        Gtk.MenuItem mi = null;

        if (lf.status == LauncherFile.Statuses.DOWNLOADED ||
            lf.status == LauncherFile.Statuses.UPLOADED)
        {
          string img = lf.status == LauncherFile.Statuses.DOWNLOADED ?
                                    Stock.GO_DOWN : Stock.GO_UP;
          var imi = new Gtk.ImageMenuItem.from_stock (img, null);
          imi.set_label (lf.get_uri ());
          mi = (Gtk.MenuItem) imi;
        }
        else
          mi = new Gtk.MenuItem.with_label (lf.get_uri ());

        mi.activate.connect ((widget) => {
          var f = LauncherFile.find_by_uri (((Gtk.MenuItem) widget).label);
          if (f != null)
            f.download ();
        });

        popmenu.add (mi);
      }
    }

    var finish_all = new Gtk.ImageMenuItem.from_stock (Stock.CLEAR, null);
    finish_all.activate.connect (() => {
      Idle.add(() => { window.finish_all_files (); return false; });
      popmenu.popdown ();
    });

    if (lfs.length () == 0)
      finish_all.sensitive = false;

    item_quit.activate.connect (window.on_window_destroy);
    item_toggle.activate.connect (set_window_visibility);

    var t_notify    = _("Enable notifications");
    var t_tray      = _("Minimize to tray");
    var item_notify = new Gtk.CheckMenuItem.with_label (t_notify);

    item_notify.set_active (App.do_notifications);
    item_notify.activate.connect (() => {
      window.toggle_notifications ((int) (!App.do_notifications));
    });

    var item_minimize = new Gtk.CheckMenuItem.with_label (t_tray);

    item_minimize.set_active (App.do_minimize);
    item_minimize.activate.connect (() => {
      window.toggle_minimize_to_tray ((int) (!App.do_minimize));
      item_minimize.sensitive = App.do_minimize;
    });

    popmenu.add (new SeparatorMenuItem ());
    popmenu.add (item_notify);
    popmenu.add (item_minimize);
    popmenu.add (new SeparatorMenuItem ());
    popmenu.add (finish_all);
    popmenu.add (item_toggle);
    popmenu.add (item_quit);
    popmenu.show_all ();
    popmenu.popup (null, null, null, btn, time);
  }

  void set_window_visibility ()
  {
    var v = window.visible;
    window.visible = !v;
    icon.tooltip_text = v ? m_show : m_hide;
  }
}
