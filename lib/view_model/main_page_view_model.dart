// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:swiping_project/model/data_structures/login_user.dart';
import 'package:swiping_project/view_model/tab_layout_view_models/preferences_page_view_model.dart';
import 'package:swiping_project/view_model/tab_layout_view_models/profile_page_view_model.dart';
import 'package:swiping_project/view_model/tab_layout_view_models/setting_page_view_model.dart';
import 'package:swiping_project/view_model/tab_layout_view_models/swipe_page_view_model.dart';
import 'package:provider/provider.dart';

import 'package:swiping_project/view/google_login_page/login_page.dart';
import 'package:swiping_project/view/tab_pages/matches_page/matches_page.dart';
import 'package:swiping_project/view/tab_pages/preferences_page/preferences_page.dart';
import 'package:swiping_project/view/tab_pages/profile_page/profile_page.dart';
import 'package:swiping_project/view/tab_pages/setting_page/setting_page.dart';
import 'package:swiping_project/view/tab_pages/swipe_page/swipe_page.dart';
import 'package:swiping_project/view_model/login_page_view_model.dart';
import 'package:swiping_project/view_model/tab_layout_view_models/matches_page_view_model.dart';


enum PageToShow
{
  loginPage(-1),
  matchesPage(0),
  swipePage(1),
  profilePage(2),
  preferencesPage(3),
  settingPage(4);

  final int value;

  const PageToShow(this.value);

  static PageToShow fromInt(int value)
  {
    return PageToShow.values.firstWhere((e) => e.value == value);
  }

}

class MainPageViewModel extends ChangeNotifier
{
  PageToShow _pageToShow = PageToShow.loginPage;//always the first page on the app

  PageToShow get pageToShow => _pageToShow;

  String? snackBar;

  void theSnackBarIsOnScreen()
  {
    snackBar = null;
  }

  void checkWhereToMove() //call only if has login user
  {
      if (LoginUser.completeProfile == false)
      {
        moveToPage(PageToShow.profilePage);
        snackBar = "מלא את הפרופיל כדי להופיע למשתמשים אחרים";
      }
      else if (LoginUser.completePreferences == false)
      {
        moveToPage(PageToShow.preferencesPage);
        snackBar = "מלא את ההעדפות כדי להופיע למשתמשים אחרים";
      }
      else if (LoginUser.visible == false)
      {
        moveToPage(PageToShow.settingPage);
        snackBar = "הפרופיל שלך לא נראה למשתמשים אחרים";
      }
      else // LoginUser.visible && LoginUser.completePreferences && LoginUser.completeProfile
        moveToPage(PageToShow.swipePage);
      notifyListeners();
  }


  void moveToPage(PageToShow newPage)
  {
    _pageToShow = newPage;
    notifyListeners();
  }

  void removeAllViewModels()
  {
      GetIt.instance.unregister<LoginPageViewModel>();
      GetIt.instance.unregister<MatchesPageViewModel>();
      GetIt.instance.unregister<SwipePageViewModel>();
      GetIt.instance.unregister<ProfilePageViewModel>();
      GetIt.instance.unregister<PreferencesPageViewModel>();
      GetIt.instance.unregister<SettingPageViewModel>();
  }


  Widget createLoginPage()
  {
    LoginPageViewModel loginPageViewModel;
    if (!GetIt.instance.isRegistered<LoginPageViewModel>())
    {
      loginPageViewModel = LoginPageViewModel();
      GetIt.instance.registerSingleton(loginPageViewModel);
    }
    else
      loginPageViewModel = GetIt.instance.get<LoginPageViewModel>();

    return (
        ChangeNotifierProvider.value(
          value : loginPageViewModel,
          child: LoginPage(),
        ));
  }


  Widget createMatchesPage()
  {
    MatchesPageViewModel matchesPageViewModel;
    if (!GetIt.instance.isRegistered<MatchesPageViewModel>())
    {
      matchesPageViewModel = MatchesPageViewModel();
      GetIt.instance.registerSingleton(matchesPageViewModel);
    }
    else
      matchesPageViewModel = GetIt.instance.get<MatchesPageViewModel>();

    return (
        ChangeNotifierProvider.value(
          value : matchesPageViewModel,
          child: MatchesPage(),
        ));
  }

  Widget createSwipePage()
  {
    SwipePageViewModel swipePageViewModel;
    if (!GetIt.instance.isRegistered<SwipePageViewModel>())
    {
      swipePageViewModel = SwipePageViewModel();
      GetIt.instance.registerSingleton(swipePageViewModel);
    }
    else
      swipePageViewModel = GetIt.instance.get<SwipePageViewModel>();

    return (
        ChangeNotifierProvider.value(
          value : swipePageViewModel,
          child: SwipePage(),
        ));
  }


  Widget createProfilePage()
  {
    ProfilePageViewModel profilePageViewModel;
    if (!GetIt.instance.isRegistered<ProfilePageViewModel>())
    {
      profilePageViewModel = ProfilePageViewModel();
      GetIt.instance.registerSingleton(profilePageViewModel);
    }
    else
      profilePageViewModel = GetIt.instance.get<ProfilePageViewModel>();

    return (
        ChangeNotifierProvider.value(
          value : profilePageViewModel,
          child: ProfilePage(),
        ));
  }

  Widget createPreferencesPage()
  {
    PreferencesPageViewModel preferencesPageViewModel;
    if (!GetIt.instance.isRegistered<PreferencesPageViewModel>())
    {
      preferencesPageViewModel = PreferencesPageViewModel();
      GetIt.instance.registerSingleton(preferencesPageViewModel);
    }
    else
      preferencesPageViewModel = GetIt.instance.get<PreferencesPageViewModel>();

    return (
        ChangeNotifierProvider.value(
          value : preferencesPageViewModel,
          child: PreferencesPage(),
        ));
  }

  Widget createSettingPage()
  {
    SettingPageViewModel settingPageViewModel;
    if (!GetIt.instance.isRegistered<SettingPageViewModel>())
    {
      settingPageViewModel = SettingPageViewModel();
      GetIt.instance.registerSingleton(settingPageViewModel);
    }
    else
      settingPageViewModel = GetIt.instance.get<SettingPageViewModel>();

    return (
        ChangeNotifierProvider.value(
          value : settingPageViewModel,
          child: SettingPage(),
        ));
  }

}