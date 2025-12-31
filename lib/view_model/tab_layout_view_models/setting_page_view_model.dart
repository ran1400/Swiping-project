
import 'package:get_it/get_it.dart';
import 'package:swiping_project/model/data_structures/login_user.dart';
import 'package:swiping_project/model/data_structures/user_setting.dart';
import 'package:swiping_project/model/google_login_model.dart';
import 'package:swiping_project/model/serverRequests/server_request.dart';
import 'package:swiping_project/view_model/tab_layout_view_models/swipe_page_view_model.dart';
import 'package:swiping_project/view_model/utils/view_model_in_the_tab_layout.dart';
import 'package:swiping_project/view_model/main_page_view_model.dart';


class SettingPageViewModel extends ViewModelInTheTabLayout
{

  UserSetting? userSetting;
  bool _showProfileChecked = LoginUser.visible;
  static bool _toGetSetting = true;

  SettingPageViewModel()
  {
    _toGetSetting = true;
  }

  bool get showProfileChecked => _showProfileChecked;
  bool get userWantToGetUpdates => userSetting!.userWantToGetUpdates;
  String get mail => userSetting!.mail;
  int get selectedDay => userSetting!.selectedDay.serverCode;
  int get selectedHour => userSetting!.selectedHour;

  pageIsInit()
  {
    if (_toGetSetting)
    {
      _toGetSetting = false;
      getUserSettingFromTheServer();
    }
  }

  static askForUserSettingOnCreatePage()
  {
    _toGetSetting = true;
  }

  void showSnackBar(String msg)
  {
    msgToUser = MsgToUser(msg : msg);
    notifyListeners();
  }

  void getUserSettingFromTheServer() async
  {
    _toGetSetting = false;
    loading = true;
    removeError();
    notifyListeners();
    Map<String,dynamic>? serverResponse = await ServerRequest.getUserSetting();
    userSetting = UserSetting.fromMap(serverResponse);
    removeLoading();
    if (userSetting == null || serverResponse!.containsKey("visible") == false)
    {
        String msg = "טעינת ההגדרות נכשלה";
        error = ErrorPageDS(msg,getUserSettingFromTheServer);
        msgToUser = MsgToUser(msg : msg);
    }
    LoginUser.visible = serverResponse!["visible"] == 1;
    _showProfileChecked = LoginUser.visible;
    notifyListeners();
  }


  void setMail(String val)
  {
    userSetting!.mail = val;
    notifyListeners();
  }

  void setDay(int? day)
  {
    userSetting!.selectedDay = DayOfWeek.fromServerCode(day!);
    notifyListeners();
  }

  void setHour(int? hour)
  {
    userSetting!.selectedHour = hour!;
    notifyListeners();
  }

  void saveBtnPressed() async
  {
      if (userSetting!.mail.isEmpty)
      {
        msgToUser = MsgToUser(msg : "אופס שכחת להכניס מייל");
        notifyListeners();
        return;
      }
      loading = true;
      notifyListeners();
      bool serverResponse = await ServerRequest.setUserSetting(userSetting!,_showProfileChecked);
      if (serverResponse)
      {
          LoginUser.visible = _showProfileChecked;
          msgToUser = MsgToUser(msg : "ההגדרות נשמרו");
          SwipePageViewModel.askForUsersOnCreatePage();
      }
      else
        msgToUser = MsgToUser(msg : "שמירת ההגדרות נכשלה");
      removeLoading();
      notifyListeners();
  }

  void userWantGetUpdatesChanged(bool checked)
  {
    userSetting!.userWantToGetUpdates = checked;
    notifyListeners();
  }

  void showMyProfilePressed(bool checked)
  {
    if (checked)
    {
      if (LoginUser.completeProfile && LoginUser.completePreferences)
        _showProfileChecked = true;
      else
        msgToUser = MsgToUser(msg : "קודם צריך להשלים את הפרופיל וההעדפות");
    }
    else
      _showProfileChecked = false;
    notifyListeners();
  }

  void logoutBtnPressed() async
  {
    loading = true;
    notifyListeners();
    bool success = await GoogleLoginModel.handleLogout();
    loading = false;
    if (success)
    {
      MainPageViewModel mainPageViewModel = GetIt.instance.get<MainPageViewModel>();
      mainPageViewModel.removeAllViewModels();
      mainPageViewModel.moveToPage(PageToShow.loginPage);
    }
    else
    {
      msgToUser = MsgToUser(msg : "ההתנתקות נכשלה");
      notifyListeners();
    }
  }

}