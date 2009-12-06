using GLib;
using Gee;
using Roxenlauncher;

namespace Roxenlauncher
{
  errordomain RoxenError
  { 
    BAD_LAUNCHERFILE,
    GENERIC
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
            error("Unable to create local directory"); 

        return f;

      case "FILES":
        var f = Path.build_filename(getdir("$home"), App.DIR, App.FILES_DIR);

        if (!FileUtils.test(f, FileTest.EXISTS)) 
          if (DirUtils.create_with_parents(f, 0750) == -1)
            error("Unable to create local directory");

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
  
	public class SimpleURI : Object
	{
		private static Regex re;
		private static HashMap<string,int> _ports;
		
		public string scheme { get; set; }
		public string host { get; set; }
		public string? username { get; set; }
		public string? password { get; set; }
		public int port { get; set; }
		public string? path { get; set; }
		public string? query { get; set; }
		public string? extra { get; set; }
		
		public SimpleURI(string uri)
		{
			if (re == null) {
			  try {
			    re = new Regex("([-+a-zA-Z0-9]+)://" + // Scheme
		                     "((.[^:]*):?(.*)?@)?" + // Userinfo
		                     "(.[^:/]*)"           + // Host
		                     ":?([0-9]{1,6})?"     + // Port
		                     "(/.[^?#]*)"          + // Path
		                     "[?]?(.[^#]*)?"       + // Query
		                     "#?(.*)?");             // Extra
        }
        catch (Error e) {
          warning("Regex error: %s", e.message);
          return;
        }
			}

			MatchInfo m;
			if (re.match(uri, RegexMatchFlags.ANCHORED, out m)) {
				string[] ss = m.fetch_all();
				
				int i = 0;
				foreach (string s in ss) {
					if (s.length == 0) {
						i++;
						continue;
					}
					
					switch (i) {
						case 1: scheme   = s.down();   break;
						case 2: /* Move along... */    break;
						case 3: username = s;          break;
						case 4: password = s;          break;
						case 5: host     = s.down();   break;
						case 6: port     = s.to_int(); break;
						case 7: path     = s;          break;
						case 8: query    = s;          break;
						case 9: extra    = s;          break;
					}

					i++; 
				}

				if (port == 0) {
					ports();
					port = _ports[scheme];
				}					
			}
			else warning("Bad URI(%s)", uri);
		}
		
		public static HashMap ports()
		{
			if (_ports == null) {
				_ports = new HashMap<string,int>();
				_ports["ftp"]    = 21;
				_ports["ssh"]    = 22;
				_ports["telnet"] = 23;
				_ports["smtp"]   = 25;
				_ports["http"]   = 80;
				_ports["https"]  = 443;
			}
			
			return _ports;
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