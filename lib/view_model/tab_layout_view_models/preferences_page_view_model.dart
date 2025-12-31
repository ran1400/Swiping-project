
import 'package:swiping_project/model/data_structures/login_user.dart';
import 'package:swiping_project/model/data_structures/user_preferences.dart';
import 'package:swiping_project/model/serverRequests/server_request.dart';
import 'package:swiping_project/view_model/tab_layout_view_models/setting_page_view_model.dart';
import 'package:swiping_project/view_model/tab_layout_view_models/swipe_page_view_model.dart';
import 'package:swiping_project/view_model/utils/view_model_in_the_tab_layout.dart';

class PreferencesPageViewModel extends ViewModelInTheTabLayout
{

    UserPreferences? userPreferences;
    static bool _toGetUserPreferences = true;

    PreferencesPageViewModel()
    {
      _toGetUserPreferences = true;
    }

    pageIsInit()
    {
      if (_toGetUserPreferences)
      {
        _toGetUserPreferences = false;
        getPreference();
      }
    }

    void getPreference()
    {
      if (LoginUser.completePreferences)
        _getPreferencesFromTheServer();
      else
      {
        userPreferences = UserPreferences.clean();
        notifyListeners();
      }
    }

    static askForUserPreferencesOnCreatePage()
    {
      _toGetUserPreferences = true;
    }

    bool allFilled()
    {
        if (userPreferences!.minAge == null || userPreferences!.maxAge == null)
          return false;
        if (userPreferences!.regionSearch.isEmpty || userPreferences!.genderSearch.isEmpty)
          return false;
        return true;
    }

    void minAgeChanged(int age)
    {
      userPreferences!.minAge = age;
      notifyListeners();
    }

    void maxAgeChanged(int age)
    {
      userPreferences!.maxAge = age;
      notifyListeners();
    }


    void searchGenderChange(int gender,bool selected)
    {
      if (selected)
        userPreferences!.genderSearch.add(gender);
      else
        userPreferences!.genderSearch.remove(gender);
      notifyListeners();
    }

    void regionSearchChanged(int region,bool selected)
    {
      if (selected)
        userPreferences!.regionSearch.add(region);
      else
        userPreferences!.regionSearch.remove(region);
      notifyListeners();
    }

    void saveBtn() async
    {
      if (allFilled() == false)
      {
        msgToUser = MsgToUser(msg : "קודם נצטרך את כל ההעדפות שלך");
        notifyListeners();
        return;
      }
      else if (userPreferences!.minAge! > userPreferences!.maxAge!)
      {
        msgToUser = MsgToUser(msg : "גיל המינימום לחיפוש לא יכול להיות גדול מגיל המקסימום");
        notifyListeners();
        return;
      }
      loading = true;
      notifyListeners();
      bool setUserVisible = LoginUser.completeProfile && LoginUser.completePreferences == false;
      bool success = await ServerRequest.setPreferences(userPreferences!,setUserVisible);
      if (success)
      {
        SettingPageViewModel.askForUserSettingOnCreatePage();
        SwipePageViewModel.askForUsersOnCreatePage();
        LoginUser.completePreferences = true;
        if (setUserVisible) //already fill the profile and now finish to fill the preferences
        {
          msgToUser = MsgToUser(msg : "ההעדפות שלך נשמרו,\nבהגדרות ניתן להגדיר קבלת עדכונים");
          LoginUser.visible = true;
        }
        else if (LoginUser.completeProfile) //already fill the profile and the preferences
          msgToUser = MsgToUser(msg : "ההעדפות שלך נשמרו");
        else //not fill yet the profile
          msgToUser = MsgToUser(msg : "ההעדפות נשמרו בהצלחה,\nכדי להתחיל להחליק צריך למלא את הפרופיל");
      }
      else
        msgToUser = MsgToUser(msg : "ארעה תקלה בשמירת ההעדפות");
      removeLoading();
      notifyListeners();
    }

    void _getPreferencesFromTheServer() async
    {
      _toGetUserPreferences = false;
      loading = true;
      removeError();
      notifyListeners();
      Map<String, dynamic>? preferences  = await ServerRequest.getPreferences();
      userPreferences = UserPreferences.fromMap(preferences);
      if (userPreferences == null)
      {
          String msg = "טעינת ההעדפות נכשלה";
          error = ErrorPageDS(msg,_getPreferencesFromTheServer);
          msgToUser = MsgToUser(msg: msg);
      }
      removeLoading();
      notifyListeners();
    }





}