// ignore_for_file: prefer_function_declarations_over_variables, curly_braces_in_flow_control_structures


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:swiping_project/model/data_structures/data_sets_from_server.dart';
import 'package:swiping_project/model/data_structures/login_user.dart';
import 'package:swiping_project/model/data_structures/user.dart';
import 'package:swiping_project/model/serverRequests/server_request.dart';
import 'package:swiping_project/model/utils/image_tools.dart';
import 'package:swiping_project/view_model/tab_layout_view_models/setting_page_view_model.dart';
import 'package:swiping_project/view_model/tab_layout_view_models/swipe_page_view_model.dart';
import 'package:swiping_project/view_model/utils/view_model_in_the_tab_layout.dart';
import 'package:swiping_project/view/tab_pages/profile_page/profile_page_utils.dart';


sealed class InputStep
{
  late String explainToUser;
  bool Function() isFilled;
  InputStep(this.explainToUser,this.isFilled);
}

class TextInputStep extends InputStep
{
  int numberOfLines;
  TextEditingController textEditingController = TextEditingController();
  Function(String) doWithInput;
  TextInputStep(super.explainToUser,this.numberOfLines,this.doWithInput,super.isFilled);
}

class DateInputStep extends InputStep
{
  Function(String?) doWithInput;
  DateInputStep(super.explainToUser,super.isFilled,this.doWithInput);
}

class ButtonInputStep extends InputStep
{
  String btnText;
  Function() onPressed;
  ButtonInputStep(super.explainToUser,super.isFilled,this.btnText,this.onPressed);
}

class ChoiceMultipleOptionsInputStep extends InputStep
{
  List<int> values;
  List<String> options;
  bool Function(int) isSelected;
  Function(int value,bool selected) itemChoose;
  ChoiceMultipleOptionsInputStep(super.explainToUser,this.values,this.options,
                                 super.isFilled,this.isSelected,this.itemChoose);
}


class ProfilePageViewModel extends ViewModelInTheTabLayout
{
    static bool _toGetUserProfile = true;
    Uint8List? _imageToCrop;
    String? _showStaticLoadingView;
    Uint8List? _smallImage;
    MyProfile? myProfile;
    late List<InputStep> steps;
    int currentStep = 0;
    late ButtonInputStep _imageStep;
    late TextInputStep _nameStep;
    late DateInputStep _birthDateStep;
    late TextInputStep _cityStep;
    late TextInputStep _aboutStep;
    late TextInputStep _contactStep;
    late ChoiceMultipleOptionsInputStep _genderStep;
    late ChoiceMultipleOptionsInputStep _regionStep;

    ProfilePageViewModel()
    {
      _toGetUserProfile = true;
      _imageStep = _createImageStep();
      _nameStep = _createNameStep();
      _birthDateStep = _createBirthDateStep();
      _cityStep = _createCityStep();
      _aboutStep = _createAboutStep();
      _contactStep = _createContactStep();
      _regionStep = _createChooseRegionStep();
      _genderStep = _createChooseGenderStep();
      steps = [_imageStep,_nameStep,_birthDateStep,_cityStep,_genderStep,_regionStep,_aboutStep,_contactStep];
    }

    Uint8List? get imageToCrop => _imageToCrop;
    String? get showStaticLoadingView => _showStaticLoadingView;

    pageIsInit()
    {
      if (_toGetUserProfile)
      {
        _toGetUserProfile = false;
        getUserProfile();
      }
    }

    void getUserProfile()
    {
      if (LoginUser.completeProfile)
        _getMyProfileFromTheServer();
      else
      {
          myProfile = MyProfile.clean();
          _initControllers();
          currentStep = 0;
          notifyListeners();
      }
    }


    InputStep getCurrentStep()
    {
      return steps[currentStep];
    }

     void _getMyProfileFromTheServer() async
     {
       _toGetUserProfile = false;
       loading = true;
       removeError();
       notifyListeners();
       Map<String, dynamic>? response = await ServerRequest.getMyProfile();
       myProfile = MyProfile.fromMap(response);
       if (myProfile == null)
       {
          String msg = "טעינת הפרופיל נכשלה";
          error = ErrorPageDS(msg,_getMyProfileFromTheServer);
          msgToUser = MsgToUser(msg : msg);
       }
       else
         _initControllers();
       removeLoading();
       currentStep = 0;
       notifyListeners();
     }


     bool allStepsFilled()
     {
       for (InputStep step in steps)
       {
         if (step.isFilled() == false)
           return false;
       }
       return true;
     }


    void saveBtn() async
    {
      if (allStepsFilled() == false)
      {
        msgToUser = MsgToUser(msg : "מלא קודם את כל הפרטים");
        notifyListeners();
        return;
      }
      loading = true;
      notifyListeners();
      Future<bool> Function() serverRequestToDo;
      bool setUserVisible = LoginUser.completeProfile == false && LoginUser.completePreferences;
      if (myProfile!.image is UrlImage)
          serverRequestToDo = () => ServerRequest.setMyProfileWithoutNewImage(myProfile!);
      else // (myProfile!.image is Uint8ListImage)
      {
        Uint8List image = (myProfile!.image as Uint8ListImage).imageBytes;
        serverRequestToDo = () => ServerRequest.setMyProfileWithNewImage(myProfile!,image,_smallImage!,setUserVisible);
      }
      bool responseFromServer = await serverRequestToDo();
      removeLoading();
      if (responseFromServer)
      {
        LoginUser.completeProfile = true;
        SwipePageViewModel.askForUsersOnCreatePage();
        SettingPageViewModel.askForUserSettingOnCreatePage();
        if (setUserVisible) //already fill the preferences and now finish to fill the profile
        {
          LoginUser.visible = true;
          msgToUser = MsgToUser(msg : "הפרופיל נשמר בהצלחה\nבהגדרות ניתן להגדיר קבלת עדכונים");
        }
        else if (LoginUser.completePreferences) //already fill the profile and the preferences
          msgToUser = MsgToUser(msg : "הפרופיל נשמר בהצלחה");
        else //not fill yet the preferences
          msgToUser = MsgToUser(msg : "הפרופיל נשמר בהצלחה\nכדי להתחיל להחליק צריך למלא את ההעדפות");
      }
      else
        msgToUser = MsgToUser(msg : "ארעה תקלה בשמירת הפרופיל ):");
      notifyListeners();
    }

    ChoiceMultipleOptionsInputStep _createChooseGenderStep()
    {
      String explainToUser = "אני";
      List<int> values = List.generate(DataSetsFromServer.genders!.length,(index) => index);
      List<String> options = DataSetsFromServer.genders!;
      bool Function() isFilled = () => myProfile!.gender != null;
      bool Function(int) isSelected = (int gender){return gender == myProfile!.gender;};
      Function(int,bool) itemChoose = (int gender,bool selected)
      {
        if (selected)
          myProfile!.gender = gender;
        else
          myProfile!.gender = null;
        notifyListeners();
      };
      return ChoiceMultipleOptionsInputStep(explainToUser,values,options,isFilled,isSelected,itemChoose);
    }

    ChoiceMultipleOptionsInputStep _createChooseRegionStep()
    {
      String explainToUser = "אני גר באזור";
      List<int> values = List.generate(DataSetsFromServer.regions!.length,(index) => index);
      List<String> options = DataSetsFromServer.regions!;
      bool Function() isFilled = () => myProfile!.regionLive.isNotEmpty;
      bool Function(int) isSelected = (int region){return myProfile!.regionLive.contains(region);};
      Function(int,bool) itemChoose = (int region,bool selected)
      {
        if (selected)
          myProfile!.regionLive.add(region);
        else
          myProfile!.regionLive.remove(region);
        notifyListeners();
      };
      return ChoiceMultipleOptionsInputStep(explainToUser,values,options,isFilled,isSelected,itemChoose);
    }

    ButtonInputStep _createImageStep()
    {
      String explainToUser = "העלה תמונה" ;
      Function(Uint8List?) doWithInput =  _userPickImage;
      bool Function() isFilled = () => myProfile!.image != null;
      String btnText = "בחר תמונה";
      Function() onPressed = () => ProfilePageUtils.handleImagePick(doWithInput);
      return ButtonInputStep(explainToUser,isFilled,btnText,onPressed);
    }

    void _userPickImage(Uint8List? image) async
    {
      if (image == null)
      {
        msgToUser = MsgToUser(msg : "בחירת התמונה נכשלה");
        notifyListeners();
        return;
      }
      String? imageType = ImageTools.getImageType(image); //get only jpeg and png
      //print("check_the image type is : $imageType");
      if (imageType == null)
      {
        msgToUser = MsgToUser(msg : "פורמט תמונה לא נתמך");
        notifyListeners();
        return;
      }
      _handleCropImage(image);
    }


    Future<void> _handleCropImage(Uint8List image) async
    {
      _showStaticLoadingView = "...טוען";
      notifyListeners();
      await Future.delayed(Duration(milliseconds: 50)); // give the ui time to update
      Uint8List? imageToCrop = await compute(ImageTools.resizeImageResToMax1500,image);
      if (imageToCrop == null)
      {
        _showStaticLoadingView = null;
        msgToUser = MsgToUser(msg : "ארעה תקלה בחיתוך התמונה");
        notifyListeners();
        return;
      }
      //print("check_ img size is : ${imageToCrop.lengthInBytes}");
      _showStaticLoadingView = null;
      _imageToCrop = imageToCrop;
      notifyListeners();
    }


    void finishCroppingImage(Uint8List? res) async
    {
      if (res == null)
      {
        _imageToCrop = null;
        notifyListeners();
        return;
      }
      _imageToCrop = null;
      _showStaticLoadingView = "...טוען";
      notifyListeners();
      _smallImage = await compute(ImageTools.getSmallImage,res);
      _showStaticLoadingView = null;
      if (_smallImage == null)
      {
          msgToUser = MsgToUser(msg : "בחירת התמונה נכשלה");
          myProfile!.image = null;
      }
      else
        myProfile!.image = res;
      notifyListeners();
    }

    TextInputStep _createNameStep()
    {
      String explainToUser = "הכנס שם" ;
      Function(String) doWithInput = (String input){myProfile!.name = input;  notifyListeners();};
      bool Function() isFilled = () => myProfile!.name.trim().isNotEmpty;
      return TextInputStep(explainToUser,1,doWithInput,isFilled);
    }


    TextInputStep _createCityStep()
    {
      String explainToUser = "אני גר ב" ;
      Function(String) doWithInput = (String input){myProfile!.city = input; notifyListeners();};
      bool Function() isFilled = () => myProfile!.city.trim().isNotEmpty;
      return TextInputStep(explainToUser,1,doWithInput,isFilled);
    }

    TextInputStep _createContactStep()
    {
      String explainToUser = "קישור לפרופיל פייסבוק" ;
      Function(String) doWithInput = (String input){myProfile!.contact = input; notifyListeners();};
      bool Function() isFilled = () => _isValidFacebookUrl(myProfile!.contact);
      return TextInputStep(explainToUser,2,doWithInput,isFilled);
    }

    bool _isValidFacebookUrl(String input)
    {
      if (input.isEmpty) return false;

      if (!input.startsWith(RegExp(r'https?://')))
        input = 'https://$input';

      try {Uri.parse(input);}
      catch (e) {return false;}

      final facebookPattern = RegExp(r'^https?://(www\.)?facebook\.com/.+$', caseSensitive: false);
      return facebookPattern.hasMatch(input);
    }

    TextInputStep _createAboutStep()
    {
      String explainToUser = "כתוב על עצמך" ;
      Function(String) doWithInput = (String input){myProfile!.about = input; notifyListeners();};
      bool Function() isFilled = () => myProfile!.about.trim().isNotEmpty;
      return TextInputStep(explainToUser,5,doWithInput, isFilled);
    }

    DateInputStep _createBirthDateStep()
    {
      String explainToUser = "הכנס תאריך לידה" ;
      Function(String?) doWithInput = _userChooseBirthDate;
      bool Function() isFilled = () => myProfile!.birthDate.isNotEmpty;
      return DateInputStep(explainToUser,isFilled,doWithInput);
    }

    void _userChooseBirthDate(String? input)
    {
      if (input != null)
      {
        myProfile!.birthDate = input;
        notifyListeners();
      }
    }

    _initControllers()
    {
      _nameStep.textEditingController.text = myProfile!.name;
      _cityStep.textEditingController.text = myProfile!.city;
      _aboutStep.textEditingController.text = myProfile!.about;
      _contactStep.textEditingController.text = myProfile!.contact;
    }


    setCurrentStep(int currentStep)
    {
      this.currentStep = currentStep;
      notifyListeners();
    }

    decreaseCurrentStep()
    {
      if (currentStep > 0)
      {
          currentStep--;
          notifyListeners();
      }
    }

    increaseCurrentStep()
    {
      if (currentStep < steps.length - 1)
      {
          currentStep++;
          notifyListeners();
      }
    }

}