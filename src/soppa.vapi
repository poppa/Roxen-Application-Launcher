[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "")]
namespace Soppa 
{
  [CCode (cname = "save_soup_data")]
  public bool save_soup_data(Soup.MessageBody data, string file);
}
