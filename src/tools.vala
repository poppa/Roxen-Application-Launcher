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

namespace Roxenlauncher
{
  errordomain RoxenError
  { 
    BAD_LAUNCHERFILE,
    GENERIC
  }

	/*
	public class ConfigFile : Object
	{
		string delim = "¤";
		string path;
		KeyFile kf;

		public ConfigFile(string path)
		{
			if (!file_exists(path)) {
				try {
					var file = File.new_for_path(path);
					var fs = file.create_readwrite(FileCreateFlags.NONE, null);
					fs.close(null);
				}
				catch (Error e) {
					critical("Unable to create config file \"%s\"!", path);
					Gtk.main_quit();
				}
			}

			this.path = path;
			kf = new KeyFile();
			try {
				kf.load_from_file(path, KeyFileFlags.NONE);				
			}
			catch (Error e) {
				message("%s", e.message);
			}
		}

		public void set_integer(string section, string key, int val)
		{
			kf.set_integer(section, key, val);
		}

		public int get_integer(string section, string key)
			throws KeyFileError
		{
			return kf.get_integer(section, key);
		}

		public void set_string(string section, string key, string val)
		{
			kf.set_string(section, key, val);
		}

		public string get_string(string section, string key)
			throws KeyFileError
		{
			return kf.get_string(section, key);
		}

		public void set_boolean(string section, string key, bool val)
		{
			kf.set_boolean(section, key, val);
		}

		public bool get_boolean(string section, string key)
			throws KeyFileError
		{
			return kf.get_boolean(section, key);
		}

		public void set_string_list(string section, string key, string[] val)
		{
			string v = implode(val, delim);
			kf.set_string(section, key, v);
		}

		public string[] get_string_list(string section, string key)
			throws KeyFileError
		{
			string s = kf.get_string(section, key);
			return s.split(delim);
		}

		public bool save() 
			throws Error
		{
			size_t len;
			Error e = null;
			string data = kf.to_data(out len, out e);

			if (e != null)
				throw e;

			try {
				var file = File.new_for_path(path);
				var fs = new DataOutputStream(file.open_readwrite(null).output_stream);
				fs.put_string(data, null);
				fs.close(null);
			}
			catch (Error e) {
				warning("Unable to save config: %s", e.message);
			}

			return true;
		}
	}
	*/
	
	public class ConfigFile : Object
	{
		GLib.List<Index> sections;
		string path;
		public string delimiter { get; set; default = ";"; }

		public ConfigFile(string path)
		{
			sections = new GLib.List<Index>();
			this.path = path;
			File file = File.new_for_path(path);
			if (FileUtils.test(path, FileTest.EXISTS)) {
				parse();
			}
			else {
				try {
					var fs = file.create_readwrite(FileCreateFlags.NONE, null);
					fs.close(null);
				}
				catch (GLib.Error e) {
					warning("Unable to create file \"%s\"!", path);
				}
			}
		}

		public void set_string(string index, string key, string val)
		{
			Index idx = get_index(index);
			if (idx == null) {
				idx = new Index(index);
				sections.append(idx);
			}

			idx.set_value(key, val);
		}

		public void set_integer(string index, string key, int val)
		{
			Index idx = get_index(index);
			if (idx == null) {
				idx = new Index(index);
				sections.append(idx);
			}

			idx.set_value(key, val.to_string());
		}

		public void set_double(string index, string key, double val)
		{
			Index idx = get_index(index);
			if (idx == null) {
				idx = new Index(index);
				sections.append(idx);
			}

			idx.set_value(key, val.to_string());
		}

		public void set_boolean(string index, string key, bool val)
		{
			Index idx = get_index(index);
			if (idx == null) {
				idx = new Index(index);
				sections.append(idx);
			}

			idx.set_value(key, val ? "true" : "false");
		}

		public void set_string_list(string index, string key, string[] val)
		{
			Index idx = get_index(index);
			if (idx == null) {
				idx = new Index(index);
				sections.append(idx);
			}

			int len = val.length;
			string s = "";
			for (uint i = 0; i < len; i++) {
				s += val[i];
				if (i+1 < len)
					s += delimiter;
			}

			idx.set_value(key, s);
		}

		public string? get_string(string index, string key)
		{
			Index.Value v = get_value(index, key);
			return v == null ? null : v.val;
		}

		public int get_integer(string index, string key)
		{
			Index.Value v = get_value(index, key);
			return v == null ? 0 : v.val.to_int();
		}

		public double get_double(string index, string key)
		{
			Index.Value v = get_value(index, key);
			return v == null ? 0 : v.val.to_double();
		}

		public bool get_boolean(string index, string key)
		{
			Index.Value v = get_value(index, key);
			return v == null ? false : v.val == "true";
		}

		public string[]? get_string_list(string index, string key)
		{
			Index.Value v = get_value(index, key);
			if (v != null)
				return v.val == null ? null : v.val.split(delimiter);
	
			return null;
		}

		public bool save()
		{
			try {
				var file = File.new_for_path(path);
				var fs = new DataOutputStream(file.open_readwrite(null).output_stream);
				fs.put_string(to_string(), null);
				fs.close(null);
			}
			catch (GLib.Error e) {
				warning("Failed saving file: %s", e.message);
				return false;
			}

			return true;
		}

		public string to_string()
		{
			string s = "";
			foreach (Index i in sections)
				s += i.to_string() + "\n";

			return s.strip();
		}

		private Index.Value? get_value(string index, string key)
		{
			Index i = get_index(index);
			if (i != null)
				return i.get_value(key);
	
			return null;	
		}

		private Index? get_index(string key)
		{
			foreach (Index idx in sections)
				if (idx.name == key)
					return idx;
			
			return null;
		}

		private void parse()
		{
			File f = File.new_for_path(path);
			try {
				string data;
				if (f.load_contents(null, out data, null, null)) {
					string[] lines = data.split("\n");
					Index idx = null;
					foreach (string line in lines) {
						line = line.strip();
						if (line.length == 0 || line[0] == ';')
							continue;

						string tmp = "";
						if (line.scanf("[%[^]]s]\n", tmp) == 1) {
							idx = new Index(tmp);
							sections.append(idx);
							continue;
						}

						if (idx == null)
							continue;

						string[] pts = line.split("=", 2);
						idx.set_value(pts[0], pts[1]);
					}
				}
			}
			catch (GLib.Error e) {
				warning("Failed parsing file: %s", e.message);
			}
		}

		internal class Index
		{
			public string name { get; set; } 
			GLib.List<Value> values;

			public Index(string name)
			{
				this.name = name;
				values = new GLib.List<Value>();
			}

			public void set_value(string k, string v)
			{
				Value val = get_value(k);
				if (val == null) {
					val = new Value(k, v);
					values.append(val);
				}
				else {
					val.key = k;
					val.val = v;
				}
			}
	
			public string to_string()
			{
				string s = "[" + name + "]\n";
				foreach (Value v in values)
					s += v.to_string() + "\n";
			
				return s;
			}
	
			public Value? get_value(string k)
			{
				foreach (Value v in values)
					if (v.key == k)
						return v;
				
				return null;
			}

			internal class Value
			{
				public string key;
				public string val;

				public Value(string k, string v)
				{
					key = k;
					val = v;
				}

				public string to_string()
				{
					return key + "=" + val;
				}
			}
		}
	}

  public string? file_get_contents(string file)
  {
    if (!FileUtils.test(file, FileTest.EXISTS)) {
      warning("No such file: %s", file);
      return null;
    }

    string output;
    try { FileUtils.get_contents(file, out output, null); }
    catch (Error e) {
      warning("%s", e.message);
    }
    return output;
  }

  public bool file_exists(string file)
  {
    return FileUtils.test(file, FileTest.EXISTS);
  }

  public string implode(string[] s, string glue)
  {
    long len = s.length;
    var str = "";
    for (int i = 0; i < len; i++) {
      str += s[i];
      if (i < len-1)
        str += glue;
    }

    return str;
  }

  public string[] slice(string[] s, uint from, uint to=0) throws RoxenError
  {
    if (to == 0) to = s.length - from;
    if (from+to > s.length)
      throw new RoxenError.GENERIC("slice(): Index is out of range");

    string[] ss = {};
    var limit = from+to;
    for (uint i = from; i < limit; i++)
      ss += s[i];

    return ss;
  }
  
  public string rtrim(string s, string tail="")
  {
    if (tail == "")
      return s.chomp();

    var str = s.dup();
    long len = tail.length;
    while (str.has_suffix(tail))
      str = str.substring(0, str.length-len);
      
    return str; 
  }
  
  public string ltrim(string s, string head="")
  {
    if (head == "")
      return s.chug();

    var str = s.dup();
    long len = head.length;
    while (str.has_prefix(head))
      str = str.substring(len);
      
    return str;
  }
  
  public string trim(string s, string chars="")
  {
    if (chars == "")
      return s.strip();

    return ltrim(rtrim(s, chars), chars);
  }
  
  public DateTime? filemtime(string path)
  {
    try {
      var f = File.new_for_path(path);
      if (f.query_exists(null)) {
        var fi = f.query_info(FILE_ATTRIBUTE_TIME_MODIFIED, 
                              FileQueryInfoFlags.NONE, null);
        TimeVal tv;
        fi.get_modification_time(out tv);
        return DateTime.timeval(tv);
      }
    }
    catch (Error e) {
      warning("get_fileinfo(): %s", e.message);
    }
    
    return null;
  }
  
  public DateTime? filectime(string path)
  {
    try {
      var f = File.new_for_path(path);
      if (f.query_exists(null)) {
        var fi = f.query_info(FILE_ATTRIBUTE_TIME_CREATED,
                              FileQueryInfoFlags.NONE, null);

        var ts = fi.get_attribute_uint64(FILE_ATTRIBUTE_TIME_CREATED);
        return DateTime.unixtime((time_t)ts);
      }
    }
    catch (Error e) {
      warning("get_fileinfo(): %s", e.message);
    }
    
    return null;
  }

  public string? getdir(string which)
  {
    switch(which.up())
    {
      case "$CURRENT": return Environment.get_current_dir();
      case "$HOME": return Environment.get_home_dir();
      case "$TMP": return Environment.get_tmp_dir();
      case "APPLICATION":
        var f = Path.build_filename(getdir("$home"), App.DIR);

        if (!FileUtils.test(f, FileTest.EXISTS))
          if (DirUtils.create(f, 0750) == -1)
            error(_("Unable to create local directory")); 

        return f;

      case "FILES":
        var f = Path.build_filename(getdir("$home"), App.DIR, App.FILES_DIR);

        if (!FileUtils.test(f, FileTest.EXISTS)) 
          if (DirUtils.create_with_parents(f, 0750) == -1)
            error(_("Unable to create local directory"));

        return f;
    }

    return null;
  }

  /**
   * Simple date and time class
   */
  public class DateTime : Object
  {
    private TimeVal tv = TimeVal();
    private Time time;

    /**
     * Creates a new DateTime object with the current time
     *
     * @return
     */
    public static DateTime now()
    {
      return new DateTime.from_now();
    }

    /**
     * Creates a new DateTime object from ++timestamp++
     *
     * @param timestamp
     * @return
     */
    public static DateTime unixtime(time_t timestamp)
    {
      return new DateTime.from_unixtime(timestamp);
    }
    
    /**
     * Creates a new DateTime object from a {@see TimeVal} struct
     *
     * @param timeval
     * @return
     */
    public static DateTime timeval(TimeVal timeval)
    {
      return new DateTime.from_timeval(timeval);
    }

    /**
     * Creates a new DateTime object.
     *
     * @param year
     * @param month
     * @param date
     * @param hour
     * @param minute
     * @param second
     */
    public DateTime(uint year=1970, uint month=1, uint date=1, uint hour=1,
                    uint minute=0, uint second=0)
    {
      var a = "%ld-%ld-%ld %ld:%ld:%ld".printf(year, month, date, hour,
                                               minute, second);
      var s = "%Y-%m-%d %T.000000Z";
      time = Time();
      time.strptime(a,s);
      tv.from_iso8601(time.format(s).replace(" ", "T"));
    }
    
    /**
     * Creates a new DateTime object from the current time
     */
    public DateTime.from_now()
    {
      tv.get_current_time();
      time = Time.local(tv.tv_sec);
    }
    
    /**
     * Creates a new DateTime object from a unix timestamp
     */
    public DateTime.from_unixtime(time_t unixtime)
    {
      time = Time.local(unixtime);
      tv.tv_sec = time.mktime();
    }
    
    /**
     * Creates a new DateTime object from a {@see TimeVal} struct
     */
    public DateTime.from_timeval(TimeVal timeval)
    {
      tv = timeval;
      time = Time.local(tv.tv_sec);
    }

    /**
     * Format time according to ++fmt++
     *
     * @param fmt
     * @return
     */
    public string format(string fmt)
    {
      return time.format(fmt);
    }
    
    /**
     * Returns the time as a string according to the current locale
     *
     * @return
     */
    public string to_string()
    {
      return time.to_string();
    }
    
    /**
     * Returns the date formatted as a ISO 8601 date
     *
     * @return
     */
    public string to_iso8601()
    {
      return tv.to_iso8601();
    }

    public time_t to_unixtime()
    {
      return time.mktime();
    }
  }

  public static class Alert
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
