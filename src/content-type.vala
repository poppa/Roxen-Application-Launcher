/* -*- Mode: Vala; indent-tabs-mode: s; c-basic-offset: 2; tab-width: 2 -*- */
/* application.vala
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

public class Roxenlauncher.ContentType : Object
{
  /**
   * List of added content types
   */
  public static unowned List<ContentType> content_types {
    get;
    private set;
    default = new List<ContentType>();
  }

  /**
   * Add content type to list of content types
   * 
   * @param ct
   */
  public static bool add_content_type (ContentType ct)
  {
    foreach (ContentType c in content_types) {
      if (ct.mimetype == c.mimetype) {
        if (Main.do_debug) 
          message ("Content type %s already in list", c.mimetype);

        return false;
      }
    }

    content_types.append (ct);
    conf.set_strv ("content-types", ContentType.to_array ());

    return true;
  }

  /**
   * Remove content type from list of content types
   * 
   * @param ct
   */
  public static void remove_content_type (ContentType ct)
  {
    content_types.remove (ct);
    conf.set_strv ("content-types", ContentType.to_array ());
  }

  /**
   * Tries to find the ContentType object with content type ct
   * 
   * @param ct
   * @return
   *  null if no object is found
   */
  public static ContentType? get_by_ct (string? ct)
  {
    if (ct == null)
      return null;

    foreach (ContentType c in content_types)
      if (c.mimetype == ct)
        return c;

    return null;
  }

  /**
   * Tries to find the editor for content type //ct//
   * 
   * @param ct
   * @return
   *  null if no editor if found
   */
  public static Editor? get_editor_for_ct (string ct)
  {
    foreach (ContentType c in content_types) {
      if (c.mimetype == ct)
        return c.editor;
    }

    return null;
  }
  
  /**
   * Turns the list of content types into an array of string representations of 
   * the objects. Suitable for storing in GSettings.
   */
  public static string[] to_array ()
  {
    string[] s = new string[] {};

    foreach (ContentType c in content_types)
      s += c.to_string ();

    return s;
  }

  /**
   * Mimetype of the content type
   */
  public string mimetype { get; set; }

  /**
   * The Editor associated to the ContentType
   */
  public Editor? editor {
    get {
      return _editor;
    }

    set {
      _editor = value;
      editor_name = _editor.name;
    }
  }

  private string editor_name = null;
  private Editor _editor = null;

  /**
   * Creates a new ContentType object
   * 
   * @param mimetype
   * @param editor_name
   * @param editor
   * */
  public ContentType (string mimetype, Editor? editor=null)
  {
    this.mimetype = mimetype;
    this.editor_name = editor.name;
    this.editor = editor;
  }

  /**
   * Creates a new instance from a string created by calling 
   * content_type.to_string() on a previous ContentType object
   *
   * @param s
   * @throws
   *  A RoxenError if the string is badly formatted
   */
  public ContentType.from_string (string s) 
    throws RoxenError
  {
    string[] pts = s.split ("\\1");

    if (pts.length != 2) {
      throw new RoxenError.ANY ("Bad argument given to constructor!  The "     +
                                "string should have been generated from "      +
                                "\"content_type.to_string()\"!");
    }

    if (pts[0].length == 0) {
      throw new RoxenError.ANY ("Bad argument given to constructor! Mimetype " +
                                "part is empty!");
    }

    if (pts[1].length == 0) {
      throw new RoxenError.ANY ("Bad argument given to constructor. Editor " +
                                "name part is empty!");
    }

    mimetype = pts[0];
    editor   = Editor.get_by_name (pts[1]);

    if (editor != null)
      editor_name = editor.name;    
  }

  /**
   * Returns the object fields as a string.
   * Each field is \\1 separated.
   */
  public string to_string ()
  {
    string en = editor_name == null ? "" : editor_name;
    return mimetype + "\\1" + en;
  }
}
