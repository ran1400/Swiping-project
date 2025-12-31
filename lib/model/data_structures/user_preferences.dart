

class UserPreferences
{
  int? minAge;
  int? maxAge;
  Set<int> genderSearch = {};
  Set<int> regionSearch = {};

  UserPreferences.clean();

  UserPreferences(int this.minAge,int this.maxAge,this.genderSearch,this.regionSearch);

  static UserPreferences? fromMap(Map<String, dynamic>? map)
  {
    if (map == null)
      return null;
    try
    {
      int minAge = map['minAge'];
      int maxAge = map['maxAge'];
      return UserPreferences(minAge, maxAge,
                             Set<int>.from(map['userSearchGender']),
                             Set<int>.from(map['regionSearch']));
    }
    catch(e)
    {
      //print(e);
      return null;
    }
  }

  Map<String,dynamic> toMap()
  {
    return {"minAge" : minAge,"maxAge" : maxAge,
            "genderSearch" : genderSearch.toList(),
            "regionSearch" : regionSearch.toList()};
  }

}
