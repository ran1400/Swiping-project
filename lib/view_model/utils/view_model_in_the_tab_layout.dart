import 'package:flutter/cupertino.dart';

class ErrorPageDS
{
  String msg;
  void Function()? retryBtn;
  ErrorPageDS(this.msg,this.retryBtn);
  ErrorPageDS.onlyMsg(this.msg);
}

class MsgToUser
{
  String msg;
  int secondsOnScreen;
  MsgToUser({this.msg = "ארעה שגיאה בטעינת הנתונים",this.secondsOnScreen = 3});
}

abstract class ViewModelInTheTabLayout extends ChangeNotifier
{
  ErrorPageDS? error;
  bool loading = false;
  MsgToUser? msgToUser;

  void removeError()
  {
    error = null;
  }

  void removeLoading()
  {
    loading = false;
  }

  void removeMsgToUser()
  {
    msgToUser = null;
  }

}

