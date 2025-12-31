
import 'package:swiping_project/model/data_structures/login_user.dart';
import 'package:swiping_project/model/data_structures/user.dart';
import 'package:swiping_project/model/serverRequests/server_request.dart';
import 'package:swiping_project/view_model/utils/view_model_in_the_tab_layout.dart';

import 'matches_page_view_model.dart';


class SwipePageViewModel extends ViewModelInTheTabLayout
{
  List<SwipeUser>? _users = [];
  static bool _toGetUsers = true;

  SwipePageViewModel()
  {
    _toGetUsers = true;
  }

  void pageIsInit()
  {
    if (_toGetUsers)
    {
      _toGetUsers = false;
      getNewUsers();
    }
  }

  static void askForUsersOnCreatePage()
  {
    _toGetUsers = true;
  }

  SwipeUser? getCrntUser()
  {
    if (_users!.isNotEmpty)
      return _users!.first;
    String msg = "לא הצלחנו למצוא משתמשים מתאימים";
    error = ErrorPageDS(msg,getNewUsers);
    return null;
  }

  getNewUsers() async
  {
    _toGetUsers = false;
    removeError();
    if (LoginUser.visible == false)
    {
        String msg = "הפרופיל שלך לא גלוי\nתוכל לשנות את הפרופיל לגלוי בהגדרות כדי לראות משתמשים חדשים";
        error = ErrorPageDS.onlyMsg(msg);
        notifyListeners();
        return;
    }
    loading = true;
    notifyListeners();
    List<SwipeUser>? newUsers = await ServerRequest.getNewUsers();
    if (newUsers == null || newUsers.isEmpty)
    {
      String msg = (newUsers == null) ? "טעינת המשתמשים נכשלה" : "לא הצלחנו למצוא משתמשים מתאימים";
      error = ErrorPageDS(msg,getNewUsers);
      msgToUser = MsgToUser(msg : msg);
    }
    _users = newUsers;
    removeLoading();
    notifyListeners();
  }

  void swipeLeft() async
  {
      int userIdGetSwipe = _users!.first.userId;
      removeError();
      loading = true;
      notifyListeners();
      bool serverResponse = await ServerRequest.swipeLeft(userIdGetSwipe);
      if (serverResponse == false)
        msgToUser = MsgToUser(msg : "אופס ההחלקה לא נרשמה אצלנו");
      else
        _users!.removeAt(0);
      removeLoading();
      notifyListeners();
  }


  void swipeRight() async
  {
    removeError();
    removeLoading();
    notifyListeners();
    bool? hasMatch = await ServerRequest.swipeRight(_users!.first.userId);
    if (hasMatch == null)
      msgToUser = MsgToUser(msg : "אופס ההחלקה לא נרשמה אצלנו");
    else if (hasMatch == true)
    {
      String msg = "גם ${_users!.first.name} החליק לך ימינה";
      msgToUser = MsgToUser(msg : msg , secondsOnScreen: 2);
      MatchesPageViewModel.askForUsersOnCreatePage();
    }
    removeLoading();
    if (hasMatch != null)
      _users!.removeAt(0);
    notifyListeners();
  }

}