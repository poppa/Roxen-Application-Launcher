using Gee;
using Roxenlauncher;

namespace Roxenlauncher
{
  namespace HTTP
  {
    const string VERSION_1_0 = "1.0";
    const string VERSION_1_1 = "1.1";

    /**
     * Class for making simple HTTP requests
     */
    public class Request : Object
    {
      /**
       * Request endpoint
       */
      private Soup.URI my_uri;
      
      /**
       * Getter/setter for the request endpoint
       */
      public Soup.URI uri {
        get { return my_uri; }
        set { my_uri = value.copy(); }
      }

      /**
       * Collection of headers to send
       */
      private HashMap<string,string> _headers = new HashMap<string,string>();

      /**
       * Getter/setter for the request headers
       */
      public HashMap<string,string> headers {
        get { return _headers; }
        set { _headers = value; } 
      }

      /**
       * HTTP version to use for the request
       */
      public string http_version { get; set; default = VERSION_1_1; }

      /**
       * Getter/setter for keep alive
       */
      public bool keep_alive { get; set; default = true; }

      /**
       * Creates a new Request object from a string uri
       *
       * @param the_uri
       */
      public Request(string the_uri)
      {
        my_uri = new Soup.URI(the_uri);
      }

      /**
       * Creates a new Request object from a URI object
       *
       * @param the_uri
       */
      public Request.from_uri(Soup.URI the_uri)
      {
        my_uri = the_uri.copy();
      }
      
      /**
       * Send request with arbitrary method
       *
       * @param method
       *  The method to use. GET, POST, PUT, DELETE etc
       * @param data
       *  Data to send in the request
       *
       * @return
       *  Returns a Response object
       */
      public Response? do_method(owned string method, owned char[]? data)
      {
        method = method.up();
        if (data == null)
          data = new char[0];

        var content_len = data.length;

        _headers["Host"] = uri.host;
        _headers["Connection"] = keep_alive ? "keep-alive" : "close";
        
        if (content_len != 0)
          _headers["Content-Length"] = content_len.to_string();

        switch (method)
        {
          case "POST":
            if (!_headers.contains("Content-Type"))
              _headers["Content-Type"] = "application/x-www-form-urlencoded";
            break;

          default: 
            if (!_headers.contains("Content-Type"))
              _headers["Content-Type"] = "text/plain";
            break;
        }

        var req = "%s %s HTTP/%s\r\n".printf(method, uri.path, http_version);
        req += headers_to_string() + "\r\n";
        
        var resolver = Resolver.get_default();
        unowned GLib.List<InetAddress> addresses;
        try {
          addresses = resolver.lookup_by_name(uri.host, null);
        }
        catch (Error e) {
          warning("Unable to resolv address for %s!", uri.host);
          return null;
        }

        var address = addresses.nth_data(0);
        var client = new SocketClient();

        try {
          var con = client.connect(new InetSocketAddress(address, 
                                                         (uint16)uri.port), 
                                                         null);
          con.output_stream.write(req, req.size(), null);
          return new Response(con.input_stream);
        }
        catch (Error e) {
          warning("Unable to connect to host %s", uri.host);
        }

        return null;
      }

      /**
       * Turns the headers collection into a string representation
       */
      string headers_to_string()
      {
        string ret = "";
        foreach (Map.Entry entry in _headers)
          ret += "%s: %s\r\n".printf((string)entry.key, (string)entry.value);

        return ret;
      }
    }
    
    /**
     * Class for parsing the response from Request
     */
    public class Response : Object
    {
      /**
       * Response headers collection
       */
      HashMap<string,string> my_headers = new HashMap<string,string>();
      /**
       * Getter for the response headers
       */
      public HashMap<string,string> headers { get { return my_headers; } }
      /**
       * The data part of the request as a string
       */
      public string data { get; private set; }
      /**
       * The HTTP header status part
       */
      HttpHeaderField response_result;
      /**
       * The raw data buffer as bytes
       */
      uint8[] data_buffer = new uint8[]{};
      /**
       * Getter for the raw data buffer
       */
      public uint8[] raw_data { get { return data_buffer; } }
      /**
       * The HTTP version of the response
       */
      public string version { get { return response_result.version; } }
      /**
       * The HTTP status code of the response
       */
      public int status_code { get { return response_result.code; } }
      /**
       * The HTTP status message of the response
       */
      public string status_text { get { return response_result.message; } }

      /**
       * Struct for the first line of the response header i.e.
       * HTTP/1.1 200 OK
       */
      public struct HttpHeaderField 
      {
        /**
         * The protocol i.e. HTTP
         */
        public string proto;
        /**
         * The HTTP version i.e. 1.1
         */
        public string version;
        /**
         * The status code
         */
        public int code;
        /**
         * The status message
         */
        public string message;

        /**
         * Parses the first line of the headers
         *
         * @param line
         *  The first line of a HTTP response
         * @return
         *  True if successful, false otherwise
         */ 
        public bool parse_line(string line)
        {
          try {
            var re = new Regex("([a-zA-Z]+)/([0-9].[0-9]) ([0-9]+) (.*)");
            MatchInfo m;
            if (re.match(line, RegexMatchFlags.ANCHORED, out m)) {
              string[] ss = m.fetch_all();
              for (long i = 0; i < ss.length; i++) {
                switch (i)
                {
                  case 1: proto   = ss[i];          break;
                  case 2: version = ss[i];          break;
                  case 3: code    = ss[i].to_int(); break;
                  case 4: message = ss[i];          break;
                }
              }
              return true;
            }
          }
          catch (Error e) {
            warning("Regex error: %s", e.message);
          }        
          return false;
        }
      }
      
      /**
       * Creates a new Response object
       *
       * @param stream
       *  The response stream from a socket call
       */
      public Response(InputStream stream)
      {
        response_result = { null, null, 0, null };
        uint8[] buf = new uint8[1024*64];
        try {
          for (;;) {
            size_t read = stream.read(buf, buf.length, null);
            if (read <= 0)
              break;

            if (read < buf.length) {
              uint8[] tmp = new uint8[read];
              Memory.copy(tmp, buf, read);
              buf = tmp;
            }

            data_buffer = concat(data_buffer, buf);
          }
        }
        catch (Error e) {
          warning("Failed to read stream: %s", e.message);
        }

        make_defaults();
      }

      /**
       * Parses the headers and body and sets up the object members
       */
      void make_defaults()
      {
        string s = "";
        for (long i = 0; i < data_buffer.length; i++)
          s += "%c".printf(data_buffer[i]);

        string[] parts = s.split("\r\n\r\n", 2);
        data_buffer = ltrim_uint8_array(data_buffer, parts[0].length + 4);
        data = parts[1];
        parse_headers(parts[0]);
      }

      /**
       * Parses the response header
       *
       * @param header
       */
      void parse_headers(string header)
      {
        long i = 0;
        foreach (string h in header.split("\r\n")) {
          i++;
          if (i == 1) {
            if (!response_result.parse_line(h))
              warning("Failed to parse HTTP response");

            continue;
          }

          long pos;
          if ((pos = strpos(h, ":")) > -1) {
            var key = h.substring(0, pos);
            var val = h.substring(pos+2);

            if (key != null && val != null)
              my_headers[key] = val;
          }
        }
      }
    }
    
    /**
     * Finds the position of needle in haystack
     *
     * @param haystack
     * @param needle
     * @return
     *  The position of needle or -1 if needle isn't found
     */
    long strpos(string haystack, string needle)
    {
      var tmp = haystack.str(needle);
      if (tmp == null)
        return -1;

      return haystack.length - tmp.length;
    }
    
    /**
     * Concatenates all and tmp
     *
     * @param all
     * @param tmp
     * @return
     */
    uint8[] concat(uint8[] all, uint8[] tmp)
    {
      uint8[] n = new uint8[all.length + tmp.length];
      ulong i = 0, j = 0;
      for (; i < all.length; i++)
        n[i] = all[i];
        
      for (; j < tmp.length; j++, i++)
        n[i] = tmp[j];

      return n;
    }
    
    /**
     * Strips off offset number of bytes from the beginning of array
     *
     * @param array
     * @param offset
     * @return
     */
    uint8[] ltrim_uint8_array(uint8[] array, long offset)
    {
      uint8[] t = new uint8[array.length - offset];
      long j = 0;
      for (long i = offset; i < array.length; i++)
        t[j++] = array[i];

      return t;
    }
  }
}