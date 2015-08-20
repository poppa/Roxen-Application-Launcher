/* -*- Mode: Vala; indent-tabs-mode: s; c-basic-offset: 2; tab-width: 2 -*- */
/* poppa.vala
 *
 * This file contains various utility methods and classes
 *
 * Copyright (C) Pontus Östlund 2009-2015 <poppanator@gmail.com>
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

namespace Poppa
{
  public errordomain Error
  {
    ANY
  }

  /**
   * Returns the content of file //file//.
   *
   * @param file
   */
  public string? file_get_contents (string file)
  {
    if (!FileUtils.test (file, FileTest.EXISTS)) {
      warning ("No such file: %s", file);
      return null;
    }

    string output;
    try { FileUtils.get_contents (file, out output, null); }
    catch (GLib.Error e) {
      warning ("%s", e.message);
    }

    return output;
  }

  /**
   * Checks if file //file// exists.
   *
   * @param file
   */
  public bool file_exists (string file)
  {
    return FileUtils.test (file, FileTest.EXISTS);
  }

  /**
   * Trims string //s// of //tail// from the end. If //tail// is omitted white
   * space characters will be removed.
   *
   * @param s
   * @param tail
   */
  public string rtrim (string s, string tail="")
  {
    if (tail == "")
      return s.chomp ();

    var str = s.dup ();
    long len = tail.length;

    while (str.has_suffix (tail))
      str = str.substring (0, str.length-len);

    return str;
  }

  /**
   * Trims string //s// of //head// from the start. If //tail// is omitted white
   * space characters will be removed.
   *
   * @param s
   * @param head
   */
  public string ltrim (string s, string head="")
  {
    if (head == "")
      return s.chug ();

    var str = s.dup ();
    long len = head.length;

    while (str.has_prefix (head))
      str = str.substring (len);

    return str;
  }

  /**
   * Trims string //s// of //chars//. If //tail// is omitted white space
   * characters will be removed.
   *
   * @param s
   * @param tail
   */
  public string trim (string s, string chars="")
  {
    if (chars == "")
      return s.strip ();

    return ltrim (rtrim (s, chars), chars);
  }

  /**
   * Returns the last modified time of //path// as a DateTime object
   *
   * @param path
   */
  public DateTime? filemtime (string path)
  {
    try {
      var f = File.new_for_path (path);
      if (f.query_exists (null)) {
        var fi = f.query_info (FileAttribute.TIME_MODIFIED,
                               FileQueryInfoFlags.NONE, null);
        TimeVal tv = fi.get_modification_time ();

        return new DateTime.from_timeval_local (tv);
      }
    }
    catch (GLib.Error e) {
      warning ("get_fileinfo(): %s", e.message);
    }

    return null;
  }

  /**
   * Returns the creation time of //path// as a DateTime object
   *
   * @param path
   */
  public DateTime? filectime (string path)
  {
    try {
      var f = File.new_for_path (path);
      if (f.query_exists (null)) {
        var fi = f.query_info (FileAttribute.TIME_CREATED,
                               FileQueryInfoFlags.NONE, null);

        var ts = fi.get_attribute_uint64 (FileAttribute.TIME_CREATED);
        return new DateTime.from_unix_local ((time_t) ts);
      }
    }
    catch (GLib.Error e) {
      warning ("get_fileinfo(): %s", e.message);
    }

    return null;
  }
}
