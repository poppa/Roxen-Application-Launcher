/* -*- Mode: Vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/*
 * tools.vala
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

using Roxenlauncher;
using Poppa;

namespace Roxenlauncher
{
  public errordomain RoxenError
  { 
    BAD_LAUNCHERFILE,
    GENERIC
  }

  public string? getdir(string which)
  {
    switch(which.up())
    {
      case "$CURRENT": return Environment.get_current_dir();
      case "$HOME": return Environment.get_home_dir();
      case "$TMP": return Environment.get_tmp_dir();
      case "APPLICATION":
        var f = Path.build_filename(getdir("$home"), DIR);

        if (!FileUtils.test(f, FileTest.EXISTS))
          if (DirUtils.create(f, 0750) == -1)
            error(_("Unable to create local directory")); 

        return f;

      case "FILES":
        var f = Path.build_filename(getdir("$home"), DIR, FILES_DIR);

        if (!FileUtils.test(f, FileTest.EXISTS)) 
          if (DirUtils.create_with_parents(f, 0750) == -1)
            error(_("Unable to create local directory"));

        return f;
    }

    return null;
  }

  class Alert
  {
    public static bool confirm(Gtk.Window parent, string message)
    {
      var md = new Gtk.MessageDialog(
        parent,
        Gtk.DialogFlags.DESTROY_WITH_PARENT,
        Gtk.MessageType.QUESTION,
        Gtk.ButtonsType.YES_NO,
        message, ""
      );

      Gtk.ResponseType resp = (Gtk.ResponseType)md.run();
      md.destroy();
      return resp == Gtk.ResponseType.YES;
    }
  }
}
