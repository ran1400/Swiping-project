
import 'package:flutter/material.dart';
import 'package:swiping_project/view_model/utils/view_model_in_the_tab_layout.dart';

mixin ViewInTheTabLayout
{
  late ViewModelInTheTabLayout viewModel;
  late BuildContext context;

  void initViewInTheTabLayout(BuildContext context, ViewModelInTheTabLayout viewModel)
  {
    this.context = context;
    this.viewModel = viewModel;
  }


  void checkIfShowSnackBar()
  {
    if (viewModel.msgToUser == null)
      return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.msgToUser!.msg,
          textAlign: TextAlign.center,
        ),

        duration: Duration(seconds: viewModel.msgToUser!.secondsOnScreen),

        behavior: SnackBarBehavior.floating,

        margin: EdgeInsets.only(
          bottom: 80, //because the navigation bar
          left: 20,
          right: 20,
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    viewModel.removeMsgToUser();
  }
}