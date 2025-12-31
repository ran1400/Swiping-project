
// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:swiping_project/model/google_login_model.dart';
import 'package:swiping_project/model/data_structures/login_user.dart';

import 'package:swiping_project/view_model/main_page_view_model.dart';


class LoginPageViewModel extends ChangeNotifier
{

    String? _snackBar;
    bool _loading = false;
    bool _userLogin = false;

    String? get msg => _snackBar;
    bool get loading => _loading;

    LoginPageViewModel()
    {
      _firstInit();
    }

    Future<void> _firstInit() async
    {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null)
        {
          _setLoadingVisiblity(true);
          _userLogin = await _checkAlreadyLoginUser(user);
          if (_userLogin)
          {
              _loading = false;
              _doOnSuccessLogin();
          }
          else
          {
              await GoogleLoginModel.handleLogout();
              _loading = false;
              notifyListeners();
          }
        }
    }

    Future<bool> _checkAlreadyLoginUser(User user) async
    {
      try
      {
        String? idToken = await user.getIdToken(true);
        if (idToken == null)
        {
          await GoogleLoginModel.handleLogout();
          return false;
        }
        return await GoogleLoginModel.enterToTheApp(idToken);
      }
      catch(e)
      {
        return false;
      }
    }

    void _doOnSuccessLogin()
    {
      LoginUser.userMail = FirebaseAuth.instance.currentUser!.email;
      MainPageViewModel mainPageViewModel = GetIt.instance.get<MainPageViewModel>();
      mainPageViewModel.checkWhereToMove();
    }


    void _setLoadingVisiblity(bool visible)
    {
      _loading = visible;
      notifyListeners();
    }


    void theMsgIsOnScreen()
    {
      _snackBar = null;
    }

    void loginBtnPressed() async
    {
        _setLoadingVisiblity(true);
        final bool res = await GoogleLoginModel.handleLogin(); //fill LoginUser static class
        _loading = false;
        if (res)
        {
            _userLogin = true;
            _doOnSuccessLogin();
        }
        else
            _snackBar = "login failed";
        notifyListeners();
    }

}