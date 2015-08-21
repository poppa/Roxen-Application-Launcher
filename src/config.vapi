/* -*- Mode: Vala; indent-tabs-mode: s; c-basic-offset: 2; tab-width: 2 -*- */
/*
 * config.vapi
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

[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "config.h")]
namespace Config {
  public const string DATADIR;
  public const string BINDIR;
  public const string GETTEXT_PACKAGE;
  public const string LOCALEDIR;
  public const string PACKAGE;
  public const string VERSION;
}
