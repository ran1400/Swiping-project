

// ignore_for_file: unnecessary_this, curly_braces_in_flow_control_structures

import 'dart:typed_data';
import 'package:swiping_project/model/data_structures/login_user.dart';
import 'package:swiping_project/model/serverRequests/server_request.dart';


sealed class MyProfileImage{}

class UrlImage extends MyProfileImage
{
  late String url;
  UrlImage(String imageName,int userId)
  {
    url = ServerRequest.getImageLink(imageName,userId);
  }
}

class Uint8ListImage extends MyProfileImage
{
  late Uint8List imageBytes;
  Uint8ListImage(this.imageBytes);
}

class User
{
  String name;
  String city;
  String about;
  String _birthDate;
  int _age;

  User(this.name,this._birthDate,this.city,this.about) : _age = calculateAge(_birthDate);

  set birthDate(String value)
  {
    _birthDate = value;
    _age = calculateAge(_birthDate);
  }

  String get birthDate => _birthDate;

  int get age => _age;

  static int calculateAge(String birthDate)
  {
    if (birthDate.isEmpty)
      return -1;
    final birthDateParsed = DateTime.tryParse(birthDate);
    if (birthDateParsed == null)
      return -1;
    final today = DateTime.now();
    int age = today.year - birthDateParsed.year;
    if (today.month < birthDateParsed.month ||
        (today.month == birthDateParsed.month && today.day < birthDateParsed.day))
    {
      age--;
    }
    return age;
  }
}

class MyProfile extends User
{
    String contact;
    int? gender;
    MyProfileImage? _image;
    Set<int> regionLive = {};

    MyProfile(super.name,super.birthDate,super.city,super.about,
              this.contact,String imageName,int this.gender,this.regionLive)
    {
      _image = UrlImage(imageName,LoginUser.userId!);
    }

    MyProfile.clean(): contact = "" , _image = null,super("","","","");


    set image(Uint8List? image) // if there are set of image is for sure not from the server
    {
      if (image == null)
        _image = null;
      else
        _image = Uint8ListImage(image);
    }

    MyProfileImage? get image => _image;

    static MyProfile? fromMap(Map<String, dynamic>? map)
    {
      if (map == null)
        return null;
      try
      {
        return MyProfile(map['name'],map['birthDate'],map['city'], map['about'],map['contact'],map['image'],
                        map['gender'],Set<int>.from(map['regionLive']));
      }
      catch(e)
      {
        //print(e);
        return null;
      }
    }

    Map<String,dynamic> toMap()
    {
      return {'city': city, 'about': about, 'contact': contact, 'name': name, 'birthDate': birthDate,
              'gender' : gender!,
              'regionLive' : regionLive.toList()};
    }

    bool allFieldsFilled()
    {
      return name.isNotEmpty && city.isNotEmpty && about.isNotEmpty && contact.isNotEmpty
              && age != 0 && image != null && gender != null && regionLive.isNotEmpty;
    }
}

class SwipeUser extends User
{
  int userId;
  late String image;
  SwipeUser(super.name,super.birthDate,super.city,super.about,String imageName,this.userId)
  {
    image = ServerRequest.getImageLink(imageName,userId);
  }

  //@override
  //String toString() {return "$name, $birthDate, $city, $about, $image, $userId";}


  static SwipeUser? fromMap(Map<String, dynamic> map)
  {
    try
    {
      return SwipeUser(map['name'],map['birthDate'],map['city'],map['about'],map['image'],map["userId"]);
    }
    catch(e)
    {
      //print(e);
      return null;
    }
  }

}

class MatchUser extends User
{
  String contact;
  int userId;
  late String image;
  late String smallImage;

  MatchUser(super.name,super.birthDate,super.city,super.about,this.contact,String imageName,this.userId)
  {
    smallImage = ServerRequest.getSmallImageLink(imageName,userId);
    image = ServerRequest.getImageLink(imageName,userId);
  }

  static MatchUser? fromMap(Map<String, dynamic>? map)
  {
    if (map == null)
      return null;
    try
    {
      return MatchUser(map['name'],map['birthDate'],map['city'],map['about'],map['contact'],map['image'],map["userId"]);
    }
    catch(e)
    {
      return null;
    }
  }
}

