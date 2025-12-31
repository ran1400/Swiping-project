
// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:swiping_project/model/data_structures/login_user.dart';
import 'package:swiping_project/model/data_structures/user.dart';
import 'package:http_parser/http_parser.dart';
import 'package:swiping_project/model/data_structures/user_preferences.dart';
import 'package:swiping_project/model/data_structures/user_setting.dart';


class ServerRequest
{

    static const String baseUrl = "https://ran-y.com/swiping-project-TEST";

    static Map<String,dynamic> getInitMap()
    {
      return {"userId" : LoginUser.userId.toString() ,"uuid": LoginUser.uuid!};
    }

    static bool fronIntToBool(int value)
    {
      return value == 1;
    }

    static String getImageLink(String image,int userId)
    {
      return "$baseUrl/images/$userId/$image";
    }

    static String getSmallImageLink(String image,int userId)
    {
      return "$baseUrl/images/$userId/smallImage/$image";
    }

    static Future<Map<String, dynamic>?> _sendRequest(Uri url,Map<String,dynamic> body,bool encodeToJson) async
    {
      try
      {
        //print("send request to : $url with map : $body");
        http.Response response;
        if (encodeToJson)
          response = await http.post(url, body : json.encode(body));
        else
          response = await http.post(url, body : body);
        if (response.statusCode != 200)
        {
          //print("check_response from url $url : ERROR statusCode != 200");
          return null;
        }
        //print("check_response from url $url : ${response.body}");
        return json.decode(response.body);
      }
      catch(e)
      {
        //print("check_response from url $url : null, error: $e" );
        return null;
      }
    }

    static Future<Map<String, dynamic>?> _sendRequestWithImages (Uri url,Map<String,dynamic> body
                                          ,Uint8List image,Uint8List smallImage) async
    {
      try
      {
        var request = http.MultipartRequest('POST', url);
        //print("send request to : $url with map : $body");
        request.files.add(http.MultipartFile.fromBytes('image', image,
            filename: 'image', contentType: MediaType('image','unknown')));
        request.files.add(http.MultipartFile.fromBytes('smallImage',smallImage,
            filename: 'smallImage', contentType: MediaType('image','unknown')));
        request.fields['data'] = json.encode(body);
        var streamedResponse = await request.send();
        if (streamedResponse.statusCode != 200)
        {
          //print("check_response from url $url : ERROR statusCode != 200");
          return null;
        }
        String responseString = await streamedResponse.stream.bytesToString();
        //print("check_response from url $url : $responseString");
        return json.decode(responseString);
      }
      catch(e)
      {
        //print("check_response from url $url : null, error: $e" );
        return null;
      }
    }

    static Future<Map<String, dynamic>?> getUserSetting() async
    {
      final url = Uri.parse("$baseUrl/getUserSetting.php");
      Map<String,dynamic> map = getInitMap();
      return await _sendRequest(url, map,false);
    }

    static Future<bool> setUserSetting(UserSetting userSetting,bool visible) async
    {
      final url = Uri.parse("$baseUrl/setUserSetting.php");
      Map<String,dynamic> map = getInitMap();
      map.addAll(userSetting.toMap(visible));
      Map<String, dynamic>?  responseMap = await _sendRequest(url,map,true);
      if (responseMap == null)
        return false;
      return responseMap.containsKey("success");
    }

    static Future<Map<String, dynamic>?> enterToTheApp(String idToken) async
    {
      final url = Uri.parse("$baseUrl/enterToTheApp.php");
      Map<String,String> map = {'idToken': idToken};
      return await _sendRequest(url, map,false);
    }

    static Future<Map<String, dynamic>?> getMyProfile() async
    {
      final url = Uri.parse("$baseUrl/getUserProfile.php");
      Map<String,dynamic> map = getInitMap();
      return await _sendRequest(url,map,false);
    }

    static Future<Map<String, dynamic>?> getPreferences() async
    {
      final url = Uri.parse("$baseUrl/getUserPreferences.php");
      Map<String,dynamic> map = getInitMap();
      return await _sendRequest(url, map,false);
    }

    static Future<bool> swipeLeft(int userGetSwipe) async
    {
      final url = Uri.parse("$baseUrl/swipeLeft.php");
      Map<String,dynamic> map = getInitMap();
      map["userGetSwipe"] = userGetSwipe.toString();
      Map<String, dynamic>?  responseMap = await _sendRequest(url,map,false);
      if (responseMap == null)
        return false;
      return responseMap.containsKey("success");
    }

    static Future<bool?> swipeRight(int userGetSwipe) async
    {
      final url = Uri.parse("$baseUrl/swipeRight.php");
      Map<String,dynamic> map = getInitMap();
      map["userGetSwipe"] = userGetSwipe.toString();
      Map<String, dynamic>?  responseMap = await _sendRequest(url,map,false);
      if (responseMap == null)
        return null;
      if (responseMap.containsKey("success") == false)
        return null;
      try {return responseMap["match"];} catch(e) {return null;}
    }

    static Future<List<SwipeUser>?> getNewUsers() async
    {
      final url = Uri.parse("$baseUrl/getNewUsers.php");
      Map<String,dynamic> map = getInitMap();
      Map<String, dynamic>? responseMap = await _sendRequest(url, map,false);
      if (responseMap == null || responseMap.containsKey("users") == false)
        return null;
      List<SwipeUser> res = [];
      for (Map<String,dynamic> user in responseMap['users'])
      {
        SwipeUser? swipeUser = SwipeUser.fromMap(user);
        if (swipeUser == null)
          return null;
        res.add(swipeUser);
      }
      return res;
    }

    static Future<List<MatchUser>?> getMatches() async
    {
      final url = Uri.parse("$baseUrl/getMatches.php");
      Map<String,dynamic> map = getInitMap();
      Map<String, dynamic>? responseMap = await _sendRequest(url, map,false);
      if (responseMap == null || responseMap.containsKey("users") == false)
        return null;
      List<MatchUser> res = [];
      for (Map<String,dynamic> user in responseMap['users'])
      {
        MatchUser? matchUser = MatchUser.fromMap(user);
        if (matchUser == null)
          return null;
        res.add(matchUser);
      }
      return res;
    }

    static Future<MatchUser?> getMatchUserProfile(int matchUserId) async
    {
      final url = Uri.parse("$baseUrl/getMatchUserProfile.php");
      Map<String,dynamic> map = getInitMap();
      map["matchUserId"] = matchUserId.toString();
      Map<String, dynamic>? responseMap = await _sendRequest(url, map,false);
      if (responseMap == null || responseMap.containsKey("user") == false)
        return null;
      MatchUser? matchUser = MatchUser.fromMap(responseMap["user"]);
      return matchUser;
    }

    static Future<bool> cancelMatch(int matchUserId) async
    {
      final url = Uri.parse("$baseUrl/cancelMatch.php");
      Map<String,dynamic> map = getInitMap();
      map["matchUserId"] = matchUserId.toString();
      Map<String, dynamic>?  responseMap = await _sendRequest(url,map,false);
      if (responseMap == null)
        return false;
      return responseMap.containsKey("success");
    }

    static Future<bool> setPreferences(UserPreferences userPreferences,bool setUserVisible) async
    {
      Map<String,dynamic> map = getInitMap();
      map["setVisible"] = setUserVisible;
      map.addAll(userPreferences.toMap());
      final url = Uri.parse("$baseUrl/setUserPreferences.php");
      Map<String, dynamic>?  responseMap = await _sendRequest(url,map,true);
      if (responseMap == null)
        return false;
      return responseMap.containsKey("success");
    }

    static Future<bool> setMyProfileWithNewImage(MyProfile myProfile,Uint8List image,Uint8List smallImage,bool setUserVisible) async
    {
      Map<String,dynamic> map = getInitMap();
      map.addAll(myProfile.toMap());
      map["setVisible"] = setUserVisible;
      final url = Uri.parse("$baseUrl/setUserProfileWithNewImage.php");
      Map<String, dynamic>?  responseMap = await _sendRequestWithImages(url,map,image,smallImage);
      if (responseMap == null)
        return false;
      return responseMap.containsKey("success");
    }


    static Future<bool> setMyProfileWithoutNewImage(MyProfile myProfile) async
    {
      Map<String,dynamic> map = getInitMap();
      map.addAll(myProfile.toMap());
      final url = Uri.parse("$baseUrl/setUserProfileWithoutImage.php");
      Map<String, dynamic>? responseMap = await _sendRequest(url,map,true);
      if (responseMap == null)
        return false;
      return responseMap.containsKey("success");
    }
}