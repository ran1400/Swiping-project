
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:swiping_project/model/data_structures/data_sets_from_server.dart';
import 'package:swiping_project/model/serverRequests/server_request.dart';
import 'package:swiping_project/model/data_structures/login_user.dart';

class GoogleLoginModel
{

  static Future<String?> _loginFromMobile() async // return idToken
  {
    try
    {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      final account = await googleSignIn.signIn();
      if (account == null)
        throw 'User canceled login';
      final auth = await account.authentication;
      var googleIdToken =  auth.idToken;
      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user == null)
        return null;
      String? firebaseIdToken = await user.getIdToken(true);
      if (firebaseIdToken == null)
      {
        await handleLogout();
        return null;
      }
      return firebaseIdToken;
    }
    catch(e)
    {
      //print("error in google sign in is : $e");
      return null;
    }
  }

  static Future<String?> _loginFromWeb() async // return idToken
  {
    try
    {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({'prompt': 'select_account'});
      UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      User? user = userCredential.user;
      if (user == null)
        return null;
      String? fireBaseIdToken = await user.getIdToken(true);
      if (fireBaseIdToken == null)
      {
        await handleLogout();
        return null;
      }
      return fireBaseIdToken;
    }
    catch(e)
    {
        return null;
    }
  }


  static Future<bool> enterToTheApp(String idToken) async
  {
    Map<String,dynamic>? serverResponse = await ServerRequest.enterToTheApp(idToken);
    if (serverResponse == null) // request failed
      return false;
    //print("check_ user login : $serverResponse");
    return DataSetsFromServer.fillValues(serverResponse) && LoginUser.fillValues(serverResponse);
  }


  static Future<bool> handleLogin() async
  {
    String? firebaseIdToken;
    if (kIsWeb) //web
      firebaseIdToken = await _loginFromWeb();
    else // Mobile
      firebaseIdToken = await _loginFromMobile();
    if (firebaseIdToken == null) //login failed;
      return false;
    return await enterToTheApp(firebaseIdToken);
  }


  static Future<bool> handleLogout() async
  {
    try
    {
      if (kIsWeb)
      {
        await FirebaseAuth.instance.signOut();
      }
      else
      {
        final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
        await googleSignIn.disconnect();
        await FirebaseAuth.instance.signOut();
      }
      return true;
    }
    catch (e)
    {
      //print(e);
      return false;
    }
  }

}
