import 'package:swiping_project/model/data_structures/login_user.dart';

enum DayOfWeek
{
  allDay("ראשון עד שבת",0),
  sunday("ראשון",1),
  monday("שני",2),
  tuesday("שלישי",3),
  wednesday("רביעי",4),
  thursday("חמישי",5),
  friday("שישי",6),
  saturday("שבת",7);

  final String name;
  final int serverCode;

  const DayOfWeek(this.name,this.serverCode);


  static DayOfWeek fromServerCode(int serverCode)
  {
    return DayOfWeek.values.firstWhere(
          (day) => day.serverCode == serverCode,
          orElse: () => throw StateError("server code -$serverCode- not exist")
    );
  }
}


class UserSetting
{

  bool userWantToGetUpdates;
  String mail;
  DayOfWeek selectedDay;
  int selectedHour;

  UserSetting(this.mail,this.selectedDay,this.selectedHour) : userWantToGetUpdates = true;

  UserSetting.withoutGetUpdates() :
    userWantToGetUpdates = false,
    mail = LoginUser.userMail!,
    selectedDay = DayOfWeek.allDay,
    selectedHour = 0;


  Map<String,dynamic> toMap(bool visible)
  {
    Map<String,dynamic> map= {};
    map["getMails"] = userWantToGetUpdates;
    map["visible"] = visible;
    if (userWantToGetUpdates)
    {
        map["userMail"] = mail;
        map["dayOfWeek"] = selectedDay.serverCode;
        map["hour"] = selectedHour;
    }
    return map;
  }

  static UserSetting? fromMap(Map<String,dynamic>? map)
  {
    if (map == null)
      return null;
    try
    {
      if (map["getMails"])
          return UserSetting(map["userMail"],DayOfWeek.fromServerCode(map["dayOfWeek"]),map["hour"]);
      else
        return UserSetting.withoutGetUpdates();
    }
    catch(e)
    {
      //print(e);
      return null;
    }
  }

  static Map<int,String>? hoursMap;

  static Map<int,String> getHoursMap() // i -> i:00
  {
    if (hoursMap != null)
      return hoursMap!;
    hoursMap = {};
    for (int i = 0; i < 24; i++)
      hoursMap![i] = '${i.toString().padLeft(2, '0')}:00';
    return hoursMap!;
  }

}