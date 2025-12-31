
import 'package:swiping_project/model/data_structures/user.dart';
import 'package:swiping_project/model/serverRequests/server_request.dart';
import 'package:swiping_project/view_model/utils/view_model_in_the_tab_layout.dart';
import 'package:url_launcher/url_launcher.dart';


class MatchesPageViewModel extends ViewModelInTheTabLayout
{

  bool profileLoading = false;
  bool profileError = false;
  MatchUser? currentOpenUser;
  int? currentUserOpenIndex;
  List<MatchUser>? users;
  static bool _toGetUsers = true;

  MatchesPageViewModel()
  {
    _toGetUsers = true;
  }

  pageIsInit()
  {
    if (_toGetUsers)
    {
      _toGetUsers = false;
      getUsers();
    }
  }

  static askForUsersOnCreatePage()
  {
    _toGetUsers = true;
  }


  void getUsers() async
  {
    _toGetUsers = false;
    removeError();
    loading = true;
    notifyListeners();
    users = await ServerRequest.getMatches();
    if (users == null || users!.isEmpty)
    {
      String msg = (users == null) ? "טעינת המאצים נכשלה" : "אין לך מאצים עדיין";
      error = ErrorPageDS(msg,getUsers);
      msgToUser = MsgToUser(msg : msg);
    }
    removeLoading();
    notifyListeners();
  }

  void getUser(int userIndex) async
  {
    currentUserOpenIndex = userIndex;
    profileLoading = true;
    profileError = false;
    notifyListeners();
    int userId = users![userIndex].userId;
    currentOpenUser  = await ServerRequest.getMatchUserProfile(userId);
    if (currentOpenUser == null)
    {
        profileError = true;
        msgToUser = MsgToUser(msg : "טעינת הפרופיל נכשלה");
    }
    profileLoading = false;
    notifyListeners();
  }

  void cancelMatch(int userIndex) async
  {
    loading = true;
    notifyListeners();
    bool res = await ServerRequest.cancelMatch(currentOpenUser!.userId);
    if (res == false)
      msgToUser = MsgToUser(msg : "ביטול המאצ לא הצליח");
    else
    {
        users!.removeAt(userIndex);
        currentOpenUser = null;
        currentUserOpenIndex = null;
        if (users!.isEmpty)
        {
          String msg = "אין לך מאצים עדיין";
          error = ErrorPageDS(msg,getUsers);
          msgToUser = MsgToUser(msg : msg);
        }
    }
    loading = false;
    notifyListeners();
  }

  void goToFacebookProfile() async
  {
      if (await canLaunchUrl(Uri.parse(currentOpenUser!.contact)))
        await launchUrl(Uri.parse(currentOpenUser!.contact), mode: LaunchMode.externalApplication);
      else
      {
          msgToUser = MsgToUser(msg : "פתיחת הקישור נכשלה");
          notifyListeners();
      }
  }

  void userPressed(int index)
  {
    if (currentUserOpenIndex == null)
      getUser(index);
    else if (currentUserOpenIndex == index)
      closeProfile();
    else
    {
      closeProfile();
      getUser(index);
    }
  }

  void closeProfile()
  {
      currentOpenUser = null;
      profileError = false;
      currentUserOpenIndex = null;
      notifyListeners();
  }

}