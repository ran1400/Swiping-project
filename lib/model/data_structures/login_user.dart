
class LoginUser
{
  static int? userId;
  static String? uuid;
  static String? userMail;
  static bool completeProfile = false;
  static bool completePreferences = false;
  static bool visible = false;

  static bool fillValues(Map<String, dynamic> data)
  {
    try
    {
      userId = data["userId"];
      uuid = data["uuid"];
      completeProfile = _fromIntToBoolean(data["completeProfile"]);
      completePreferences = _fromIntToBoolean(data["completePreferences"]);
      visible = _fromIntToBoolean(data["visible"]);
      return true;
    }
    catch(e)
    {
      return false;
    }

  }

  static bool _fromIntToBoolean(int num)
  {
    if (num == 0)
      return false;
    return true;
  }
}