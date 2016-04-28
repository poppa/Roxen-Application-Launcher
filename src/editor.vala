/* -*- Mode: Vala; indent-tabs-mode: s; c-basic-offset: 2; tab-width: 2 -*- */
/* editor.vala
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

public class Roxenlauncher.Editor : Object
{
	private static List<Editor> _editors =
		new List<Editor> ();

  /**
   * List of available editors
   */
  public static List<Editor> editors {
    get {
  		return _editors;
    }
  }

  /**
   * Append editor to list of editors
   *
   * @param editor
   */
  public static void add_editor (Editor editor)
  {
    foreach (Editor e in _editors) {
      if (e.name.down () == editor.name.down ()) {
        if (App.do_debug)
          message ("Editor %s already in list", editor.name);
        return;
      }
    }

    editors.append (editor);
    conf.set_strv ("editors", Editor.to_array ());
  }

  /**
   * Remove editor from list
   *
   * @param editor
   */
  public static void remove_editor (Editor editor)
  {
    _editors.remove (editor);
    conf.set_strv ("editors", Editor.to_array ());
  }

  /**
   * Tries to find Editor by name
   *
   * @param name
   * @return
   *  null if no Editor is found
   */
  public static Editor? get_by_name (string name)
  {
    foreach (Editor e in _editors)
      if (e.name.down () == name.down ())
        return e;

    return null;
  }

  /**
   * Turns the list of editors into an array of string representations of the
   * objects. Suitable for storing in GSettings
   */
  public static string[] to_array ()
  {
    string[] s = new string[] {};

    foreach (Editor e in _editors)
      s += e.to_string ();

    return s;
  }

  /**
   * Name of the editor
   */
  public string name { get; private set; }
  /**
   * Editor command line command
   */
  public string command { get; private set; }
  /**
   * Editor icon name (if any)
   */
  public string? icon { get; private set; }

  private Gdk.Pixbuf _pixbuf = null;

  /**
   * Getter for getting the icon as a Pixbuf
   */
  public Gdk.Pixbuf? pixbuf {
    get {
      if (_pixbuf != null)
        return _pixbuf;

      try { _pixbuf = Gtk.IconTheme.get_default ().load_icon (icon, 16, 0); }
      catch (GLib.Error e) {
        message ("Failed getting icon for %s: %s", name, e.message);
      }

      return _pixbuf;
    }
    private set {}
  }

  /**
   * Creates a new Editor object
   *
   * @param name
   * @param command
   * @param icon
   *  This should be the icon name as given by GLib.AppInfo (GIO)
   */
  public Editor (string name, string command, string? icon=null)
  {
    this.name = name;
    this.command = command;
    this.icon = icon;
  }

  /**
   * Creates a new instance from a string created by calling editor.to_string()
   * on a previous Editor object
   *
   * @param s
   * @throws
   *  A RoxenError if the string is badly formatted
   */
  public Editor.from_string (string s)
    throws RoxenError
  {
    string[] pts = s.split ("\\1");

    if (pts.length != 3) {
      throw new RoxenError.ANY ("Bad argument given to constructor! The "      +
                                "string should have been generated from "      +
                                "\"editor.to_string()\"!");
    }

    if (pts[0].length == 0) {
      throw new RoxenError.ANY ("Bad argument given to constructor! The  "     +
                                "first field in the string is of zero length");
    }

    if (pts[1].length == 0) {
      throw new RoxenError.ANY ("Bad argument given to constructor! The "      +
                                "second field in the string is of zero length");
    }

    name = pts[0];
    command = pts[1];

    if (pts[2].length > 0)
      icon = pts[2];
  }

  /**
   * Returns the object fields as a string.
   * Each field is \\1 separated
   */
  public string to_string ()
  {
    string ico = icon == null ? "" : icon;
    return name + "\\1" + command + "\\1" + ico;
  }
}
