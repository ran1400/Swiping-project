


class DataSetsFromServer
{
    static List<String>? regions;
    static List<String>? genders;

    static bool fillValues(Map<String, dynamic> data)
    {
      try
      {
        regions = List<String>.from(data["regions"]);
        genders = List<String>.from(data["genders"]);
        if(regions == null|| genders == null)
          return false;
      }
      catch(e)
      {
        return false;
      }
      return true;
    }
}
